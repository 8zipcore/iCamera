//
//  CutImageView.swift
//  iCamera
//
//  Created by 홍승아 on 10/5/24.
//

import SwiftUI

struct CutImageView: View {
    
    @State var image: UIImage
    @State var frameWidth: CGFloat
    @State var frameHeight: CGFloat
    
    @StateObject var cutImageManager: CutImageManager
    
    @State private var frameLocation: CGPoint = .zero
    @State private var maskRectangleViewLocation: CGPoint = .zero
    
    @State private var imagePosition: CGPoint = .zero
    @State private var lastImagePosition: CGPoint = .zero
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1
    @State private var lastImageSize: CGSize = .zero
    @State private var originalImageSize: CGSize = .zero
    
    @State private var previousFrameSize: CGSize = .zero
    
    func isPossibleImageDrag(newPosition: CGFloat, framePosition: CGFloat, imageSize: CGFloat, viewSize: CGFloat) -> Bool{
        if framePosition - imageSize / 2 < newPosition - (viewSize * zoomScale / 2) || framePosition + imageSize / 2 > newPosition + (viewSize * zoomScale / 2){
            return false
        }
        return true
    }
    
    var body: some View {
        GeometryReader { gemotry in
            let viewWidth = gemotry.size.width
            let viewHeight = gemotry.size.height
            
            ZStack{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(zoomScale)
                    .onReceive(cutImageManager.imageZoom){ value in
                        let minScale: CGFloat = 1
                        let maxScale: CGFloat = 6
                        let newScale = lastZoomScale * value
                        
                        if newScale >= minScale && newScale <= maxScale {
                            zoomScale = lastZoomScale * value
                        }
                    }
                    .onReceive(cutImageManager.imageZoomEnded) {
                        lastZoomScale = zoomScale
                    }
                    .onReceive(cutImageManager.imageDrag){ value in
                        let newPositionX = lastImagePosition.x + value.x
                        let newPositionY = lastImagePosition.y + value.y
                        
                        imagePosition.x = isPossibleImageDrag(newPosition: newPositionX, framePosition: frameLocation.x, imageSize: frameWidth, viewSize: originalImageSize.width) ? newPositionX : imagePosition.x
                        imagePosition.y = isPossibleImageDrag(newPosition: newPositionY, framePosition: frameLocation.y, imageSize: frameHeight, viewSize: originalImageSize.height) ? newPositionY : imagePosition.y
                    }
                    .onReceive(cutImageManager.imageDragEnded){ value in
                        lastImagePosition = imagePosition
                    }
                    .position(imagePosition)
                    .clipped()
                
                /*
                MaskRectangleView(overlayColor: UIColor.black.withAlphaComponent(0.3),
                                  rectangleSize: previousFrameSize,
                                  maskRectangleSize: CGSize(width: frameWidth, height: frameHeight),
                                  maskPosition: maskRectangleViewLocation)
                 */
                
                let lineSize = CGSize(width: 4, height: 20)
                
                SelectionFrameView(imageWidth: frameWidth, imageHeight: frameHeight, lineSize: lineSize, cutImageManager: cutImageManager)
                    .frame(width: frameWidth, height: frameHeight)
                    .onReceive(cutImageManager.selectionFrameDrag){ data in
                        let currentSize = CGSize(width: frameWidth, height: frameHeight)
                        let selectionFrameRectangle = data.selectionFrameRectangle
                        var newSize = CGSize(width: data.position.x, height: data.position.y)
                        let scale = data.selectionFrameRectangle.scale
                        var newLocation: CGPoint = frameLocation
                        
                        switch selectionFrameRectangle.location{
                        case .tt:
                            let widthDifferenceValue = (newSize.width - currentSize.width) * scale.x // 1
                            let heightDifferenceValue = newSize.height * scale.y // -1
                            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y - heightDifferenceValue / 2)
                        case .tb:
                            let widthDifferenceValue = (newSize.width - currentSize.width) * scale.x
                            let heightDifferenceValue = (newSize.height - currentSize.height) * scale.y
                            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .lt:
                            let widthDifferenceValue = newSize.width
                            let heightDifferenceValue = newSize.height
                            newSize = CGSize(width: currentSize.width - widthDifferenceValue, height: currentSize.height - heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .lb:
                            let widthDifferenceValue = newSize.width
                            let heightDifferenceValue = (newSize.height - currentSize.height)
                            newSize = CGSize(width: currentSize.width - widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .tc: fallthrough
                        case .b:
                            let widthDifferenceValue = (newSize.width - currentSize.width) * scale.x
                            let heightDifferenceValue = (newSize.height - currentSize.height) * scale.y
                            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .t: fallthrough
                        case .lc:
                            let widthDifferenceValue = newSize.width * scale.x
                            let heightDifferenceValue = newSize.height * scale.y
                            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x - widthDifferenceValue / 2, y: frameLocation.y - heightDifferenceValue / 2)
                        }
                        
                        let minimumSize = CGSize(width: viewWidth * 0.2, height: viewWidth * 0.2)
                        
                        if newSize.width < minimumSize.width {
                            newSize.width = minimumSize.width
                        }
                        
                        if newSize.height < minimumSize.height {
                            newSize.height = minimumSize.height
                        }
                        
                        if newSize.width > viewWidth{
                            newSize.width = viewWidth
                        }
                        
                        if newSize.height > viewHeight{
                            newSize.height = viewHeight
                        }
                        
                        if newLocation.x < (newSize.width / 2) || newLocation.x + (newSize.width / 2) > viewWidth {
                             return
                        }
                        
                        if newLocation.y < (newSize.height / 2) || newLocation.y + (newSize.height / 2) > viewHeight {
                             return
                        }
                    
                        self.frameWidth = newSize.width
                        self.frameHeight = newSize.height
                        self.frameLocation = newLocation
                        // self.maskRectangleViewLocation
                    }
                    .onReceive(cutImageManager.selectionFrameDragEnded){ data in
                        if frameWidth < viewWidth || frameHeight < viewHeight {
                            var newImageWidth = frameWidth
                            var newImageHeight = frameHeight
                            
                            var imageScale: CGFloat = 1
                            
                            if frameWidth > frameHeight{
                                newImageHeight = min(viewWidth * frameHeight / frameWidth, viewHeight)
                                newImageWidth = newImageHeight * frameWidth / frameHeight
                                zoomScale *= newImageWidth / frameWidth
                                imageScale = newImageWidth / frameWidth
                            } else {
                                newImageWidth = min(viewHeight * frameWidth / frameHeight, viewWidth)
                                newImageHeight = newImageWidth * frameHeight / frameWidth
                                zoomScale *= newImageHeight / frameHeight
                                imageScale = newImageHeight / frameHeight
                            }
                            
                            frameLocation = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
                            
                            // 드래그하기 전 프레임상태를 기준으로 1좌표를 구한다음
                            // 변화한 스케일만큼 1좌표도 증가시킨다(currentFramePostion)
                            // 1좌표를 newPosition으로 옮겨야되므로
                            // newpostion과 1좌표의 차이값을 구한 후
                            // imagePostion을 scale만큼 변화시킨 (NewImageCenter) 좌표에 차잇값을 더한다.
                            let widthChange = (lastImageSize.width - frameWidth) / 2
                            let heightChange = (lastImageSize.height - frameHeight) / 2
                            
                            let newImageCenter = CGPoint(x: imagePosition.x * imageScale, y: imagePosition.y * imageScale)
                            
                            let location = data.selectionFrameRectangle.location
                            
                            // currentPosition은 고정되어있는 좌표를 구해야함
                            switch location{
                            case .lt:
                                // 우하단 좌표 고정
                                let currentPosition = CGPoint(x: (frameLocation.x + previousFrameSize.width / 2) * imageScale, y: (frameLocation.y + previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x + newImageWidth / 2, y: frameLocation.y + newImageHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            case .t:
                                imagePosition.y -= heightChange
                            case .tt:
                                // 좌하단 좌표
                                let currentPosition = CGPoint(x: (frameLocation.x - previousFrameSize.width / 2) * imageScale, y: (frameLocation.y + previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x - newImageWidth / 2, y: frameLocation.y + newImageHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            case .lc:
                                imagePosition.x -= widthChange
                            case .tc:
                                imagePosition.x += widthChange
                            case .lb:
                                // 우상단
                                let currentPosition = CGPoint(x: (frameLocation.x + previousFrameSize.width / 2) * imageScale, y: (frameLocation.y - previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x + newImageWidth / 2, y: frameLocation.y - newImageHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            case .b:
                                imagePosition.y += heightChange
                            case .tb:
                                // 좌상단 좌표
                                let currentPosition = CGPoint(x: (frameLocation.x - previousFrameSize.width / 2) * imageScale, y: (frameLocation.y - previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x - newImageWidth / 2, y: frameLocation.y - newImageHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            }
                            
                            lastZoomScale = zoomScale
                            
                            frameWidth = newImageWidth
                            frameHeight = newImageHeight
                            previousFrameSize = CGSize(width: newImageWidth, height: newImageHeight)
                            lastImageSize = CGSizeMake(frameWidth, frameHeight)
                            lastImagePosition = imagePosition
                            // maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                        }
                    }
                    .position(frameLocation)
            }
            .frame(width: viewWidth, height: viewHeight)
            .background(.clear)
            .onAppear(perform: {
                let center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
                imagePosition = center
                lastImagePosition = imagePosition
                
                frameLocation = center
        
                originalImageSize = CGSizeMake(frameWidth, frameHeight)
                lastImageSize = CGSizeMake(frameWidth, frameHeight)
                previousFrameSize = CGSizeMake(frameWidth, frameHeight)
            })
        }
    }
}
