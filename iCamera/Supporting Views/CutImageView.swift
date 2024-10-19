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
    
    @State var padding: CGFloat
    
    @State private var frameLocation: CGPoint = .zero
    @State private var maskRectangleViewLocation: CGPoint = .zero
    
    @State private var imagePosition: CGPoint = .zero
    @State private var lastImagePosition: CGPoint = .zero
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1
    @State private var originalImageSize: CGSize = .zero
    
    @State private var previousFrameSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width - padding
            let viewHeight = geometry.size.height - padding
            
            let viewCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let lineSize = CGSize(width: 4, height: 20)
            
            ZStack{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(zoomScale)
                    .onReceive(cutImageManager.imageZoom){ value in
                        let minScale: CGFloat = 1
                        let maxScale: CGFloat = 10
                        var newScale = lastZoomScale * value
                        
                        if newScale < minScale{
                            newScale = minScale
                        } else if newScale > maxScale {
                            newScale = maxScale
                        }
                        
                        zoomScale = newScale
                    }
                    .onReceive(cutImageManager.imageZoomEnded) {
                        
                        if zoomScale * originalImageSize.width < frameWidth{
                            zoomScale *= frameWidth / (zoomScale * originalImageSize.width)
                        } else if zoomScale * originalImageSize.height < frameHeight {
                            zoomScale *= frameHeight / (zoomScale * originalImageSize.height)
                        }
                        
                        lastZoomScale = zoomScale
                        
                        let framePositionArray = cutImageManager.positionArray(center: frameLocation, width: frameWidth, height: frameHeight)
                        let imagePositionArray = cutImageManager.positionArray(center: imagePosition, width: originalImageSize.width * zoomScale, height: originalImageSize.height * zoomScale)
                        
                        // Selectionframe과 공간이 생길 때 frame이에 맞게 position 옮겨주는 작업
                        imagePosition = cutImageManager.updateImagePosition(framePositionArray: framePositionArray,
                                                                            imagePositionArray: imagePositionArray,
                                                                            imagePosition: imagePosition)
                    }
                    .onReceive(cutImageManager.imageDrag){ value in
                        let newPositionX = lastImagePosition.x + value.x
                        let newPositionY = lastImagePosition.y + value.y
                        
                        if frameLocation.x - frameWidth / 2 < newPositionX - (originalImageSize.width * zoomScale / 2){
                            imagePosition.x = frameLocation.x + (originalImageSize.width * zoomScale - frameWidth) / 2
                        } else if frameLocation.x + frameWidth / 2 > newPositionX + (originalImageSize.width * zoomScale / 2){
                            imagePosition.x = frameLocation.x - (originalImageSize.width * zoomScale - frameWidth) / 2
                        } else {
                            imagePosition.x = newPositionX
                        }
                        
                        if frameLocation.y - frameHeight / 2 < newPositionY - (originalImageSize.height * zoomScale / 2){
                            imagePosition.y = frameLocation.y + (originalImageSize.height * zoomScale - frameHeight) / 2
                        } else if frameLocation.y + frameHeight / 2 > newPositionY + (originalImageSize.height * zoomScale / 2){
                            imagePosition.y = frameLocation.y - (originalImageSize.height * zoomScale - frameHeight) / 2
                        } else {
                            imagePosition.y = newPositionY
                        }
                    }
                    .onReceive(cutImageManager.imageDragEnded){ value in
                        lastImagePosition = imagePosition
                    }
                    .frame(width: originalImageSize.width, height: originalImageSize.height)
                    .position(imagePosition)
                    .clipped()
                
                MaskRectangleView(overlayColor: UIColor.black.withAlphaComponent(0.3),
                                  rectangleSize: geometry.size,
                                  maskRectangleSize: CGSize(width: frameWidth + lineSize.width, height: frameHeight),
                                  maskPosition: CGPoint(x: maskRectangleViewLocation.x - lineSize.width / 2, y: maskRectangleViewLocation.y))
                
                SelectionFrameView(imageWidth: frameWidth + lineSize.width, imageHeight: frameHeight, lineSize: lineSize, cutImageManager: cutImageManager)
                    .frame(width: frameWidth + padding, height: frameHeight + padding)
                    .onReceive(cutImageManager.selectionFrameDrag){ data in
                        let currentSize = CGSize(width: frameWidth, height: frameHeight)
                        let selectionFrameRectangle = data.selectionFrameRectangle
                        var newSize = CGSize(width: data.position.x, height: data.position.y)
                        let scale = data.selectionFrameRectangle.scale
                        var newLocation: CGPoint = frameLocation
                        let location = selectionFrameRectangle.location
                        
                        switch location{
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
                        
                        let previousFramePositionArray = cutImageManager.positionArray(center: viewCenter, width: previousFrameSize.width, height: previousFrameSize.height)
                        let framePositionArray = cutImageManager.positionArray(center: newLocation, width: newSize.width, height: newSize.height)
                        let imagePositionArray = cutImageManager.positionArray(center: imagePosition, width: originalImageSize.width * zoomScale, height: originalImageSize.height * zoomScale)
                        
                        // frame이 이미지 사이즈 넘어가지 않도록 조정하는 작업
                        let updateData = cutImageManager.updateFrameData(location: location,
                                                                         previousFramePositionArray: previousFramePositionArray,
                                                                         framePositionArray: framePositionArray,
                                                                         imagePositionArray: imagePositionArray,
                                                                         viewWidth: geometry.size.width, viewHeight: geometry.size.height,
                                                                         viewCenter: viewCenter,
                                                                         newSize: newSize, newLocation: newLocation,
                                                                         framePosition: frameLocation,
                                                                         frameWidth: frameWidth,
                                                                         frameHeight: frameHeight)
                        newSize = updateData.0
                        newLocation = updateData.1
                        
                        let minimumSize = CGSize(width: viewWidth * 0.2, height: viewWidth * 0.2)
                        // 조건 1. 최소 사이즈보다 작아지지 않을 것
                        if newSize.width < minimumSize.width || newSize.height < minimumSize.height{
                            return
                        }
                        // 조건 2. Frame이 viewSize를 넘어가지 말 것
                        if newLocation.x - (newSize.width / 2) < padding / 2 {
                            if location == .lt || location == .lc || location == .lb{
                                newSize.width = previousFramePositionArray[4].x - padding / 2
                                newLocation.x = frameLocation.x + (newSize.width - frameWidth) / 2
                            }
                        } else if newLocation.x + (newSize.width / 2) > geometry.size.width - padding / 2 {
                            if location == .tt || location == .tc || location == .tb{
                                newSize.width =  geometry.size.width - padding / 2 - previousFramePositionArray[3].x
                                newLocation.x = frameLocation.x - (newSize.width - frameWidth) / 2
                            }
                        } else if newLocation.y - (newSize.height / 2) < padding / 2 {
                            if location == .t || location == .lt || location == .tt{
                                newSize.height = geometry.size.height - padding / 2 - previousFramePositionArray[1].y
                                newLocation.y = frameLocation.y - (newSize.height - frameHeight) / 2
                            }
                        } else if newLocation.y + (newSize.height / 2) > geometry.size.height - padding / 2 {
                            if location == .b || location == .lb || location == .tb{
                                newSize.height = previousFramePositionArray[6].y - padding / 2
                                newLocation.y = frameLocation.y + (newSize.height - frameHeight) / 2
                            }
                        }
                        
                        self.frameWidth = newSize.width
                        self.frameHeight = newSize.height
                        self.frameLocation = newLocation
                        maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                    }
                    .onReceive(cutImageManager.selectionFrameDragEnded){ data in
                        if frameWidth < viewWidth || frameHeight < viewHeight {
                            var newFrameWidth = frameWidth
                            var newFrameHeight = frameHeight
                            
                            var imageScale: CGFloat = 1
                            
                            if frameWidth > frameHeight{
                                newFrameHeight = min(viewWidth * frameHeight / frameWidth, viewHeight)
                                newFrameWidth = newFrameHeight * frameWidth / frameHeight
                                imageScale = newFrameWidth / frameWidth
                            } else {
                                newFrameWidth = min(viewHeight * frameWidth / frameHeight, viewWidth)
                                newFrameHeight = newFrameWidth * frameHeight / frameWidth
                                imageScale = previousFrameSize.height / frameHeight
                            }
                            
                            frameLocation = viewCenter
                            
                            // 드래그하기 전 프레임상태를 기준으로 1좌표를 구한다음
                            // 변화한 스케일만큼 1좌표도 증가시킨다(currentFramePostion)
                            // 1좌표를 newPosition으로 옮겨야되므로
                            // newpostion과 1좌표의 차이값을 구한 후
                            // imagePostion을 scale만큼 변화시킨 (NewImageCenter) 좌표에 차잇값을 더한다.
                            
                            let newImageCenter = CGPoint(x: imagePosition.x * imageScale, y: imagePosition.y * imageScale)
                            
                            let location = data.selectionFrameRectangle.location
                            
                            // currentPosition은 고정되어있는 좌표를 구해야함
                            switch location{
                            case .lt:
                                // 우하단 좌표 고정
                                let currentPosition = CGPoint(x: (frameLocation.x + previousFrameSize.width / 2) * imageScale, y: (frameLocation.y + previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x + newFrameWidth / 2, y: frameLocation.y + newFrameHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            case .t: fallthrough
                            case .tt:
                                // 좌하단 좌표
                                let currentPosition = CGPoint(x: (frameLocation.x - previousFrameSize.width / 2) * imageScale, y: (frameLocation.y + previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x - newFrameWidth / 2, y: frameLocation.y + newFrameHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            case .lc: fallthrough
                            case .lb:
                                // 우상단
                                let currentPosition = CGPoint(x: (frameLocation.x + previousFrameSize.width / 2) * imageScale, y: (frameLocation.y - previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x + newFrameWidth / 2, y: frameLocation.y - newFrameHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            case .tc: fallthrough
                            case .b: fallthrough
                            case .tb:
                                // 좌상단 좌표
                                let currentPosition = CGPoint(x: (frameLocation.x - previousFrameSize.width / 2) * imageScale, y: (frameLocation.y - previousFrameSize.height / 2) * imageScale)
                                let newPosition = CGPoint(x: frameLocation.x - newFrameWidth / 2, y: frameLocation.y - newFrameHeight / 2)
                                imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            }
                            
                            zoomScale *= imageScale
                            lastZoomScale = zoomScale
                            
                            frameWidth = newFrameWidth
                            frameHeight = newFrameHeight
                            previousFrameSize = CGSize(width: newFrameWidth, height: newFrameHeight)
                            lastImagePosition = imagePosition
                            maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                        }
                    }
                    .onReceive(cutImageManager.frameRatioTapped){ ratio in
                        var newFrameWidth = frameWidth
                        var newFrameHeight = frameHeight
                        
                        if frameWidth > frameHeight{
                            newFrameHeight = min(frameWidth * ratio.heightRatio / ratio.widthRatio, viewHeight)
                            newFrameWidth = newFrameHeight * ratio.widthRatio / ratio.heightRatio
                        } else {
                            newFrameWidth = min(frameHeight * ratio.widthRatio / ratio.heightRatio, viewWidth)
                            newFrameHeight = newFrameWidth * ratio.heightRatio / ratio.widthRatio
                        }

                        if zoomScale * originalImageSize.width < newFrameWidth{
                            zoomScale *= newFrameWidth / (zoomScale * originalImageSize.width)
                        }
                        
                        if zoomScale * originalImageSize.height < newFrameHeight {
                            zoomScale *= newFrameHeight / (zoomScale * originalImageSize.height)
                        }
                        
                        frameWidth = newFrameWidth
                        frameHeight = newFrameHeight
                        
                        maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                    }
                    .position(frameLocation)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(.clear)
            .onAppear(perform: {
                imagePosition = viewCenter
                lastImagePosition = imagePosition
                
                frameLocation = viewCenter
                maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                
                originalImageSize = CGSizeMake(frameWidth, frameHeight)
                previousFrameSize = CGSizeMake(frameWidth, frameHeight)
                
                if let imageRatio = cutImageManager.reduceFraction(numerator: Int(frameWidth), denominator: Int(frameHeight)){
                    cutImageManager.imageRatio = CGSize(width: imageRatio.0, height: imageRatio.1)
                }
            })
        }
    }
}
