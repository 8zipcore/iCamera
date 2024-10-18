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
        GeometryReader { gemotry in
            let viewWidth = gemotry.size.width - padding
            let viewHeight = gemotry.size.height - padding
            
            let viewCenter = CGPoint(x: gemotry.size.width / 2, y: gemotry.size.height / 2)
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
                        
                        if framePositionArray[0].x < imagePositionArray[0].x && framePositionArray[0].y < imagePositionArray[0].y{ // 좌상단 빌 때
                            imagePosition.x -= imagePositionArray[0].x - framePositionArray[0].x
                            imagePosition.y -= imagePositionArray[0].y - framePositionArray[0].y
                            // print("좌상단")
                        } else if framePositionArray[2].x > imagePositionArray[2].x && framePositionArray[2].y < imagePositionArray[2].y { // 우상단
                            imagePosition.x += framePositionArray[2].x - imagePositionArray[2].x
                            imagePosition.y -= imagePositionArray[2].y - framePositionArray[2].y
                            // print("우상단")
                        } else if framePositionArray[1].y < imagePositionArray[1].y { // 상단
                            imagePosition.y -= imagePositionArray[1].y - framePositionArray[1].y
                            // print("상단")
                        } else if framePositionArray[5].x < imagePositionArray[5].x && framePositionArray[5].y > imagePositionArray[5].y { // 좌하단
                            imagePosition.x -= imagePositionArray[5].x - framePositionArray[5].x
                            imagePosition.y += framePositionArray[5].y - imagePositionArray[5].y
                            // print("좌하단")
                        } else if framePositionArray[7].x > imagePositionArray[7].x && framePositionArray[7].y > imagePositionArray[7].y { // 우하단
                            imagePosition.x += framePositionArray[7].x - imagePositionArray[7].x
                            imagePosition.y += framePositionArray[7].y - imagePositionArray[7].y
                            // print("우하단")
                        } else if framePositionArray[6].y > imagePositionArray[6].y { // 하단
                            imagePosition.y -= framePositionArray[6].y - imagePositionArray[6].y
                            // print("하단")
                        } else if framePositionArray[3].x < imagePositionArray[3].x { // 중간 좌측
                            imagePosition.x -= imagePositionArray[3].x - framePositionArray[3].x
                            // print("중간좌측")
                        } else if framePositionArray[4].x > imagePositionArray[4].x { // 중간 우측
                            imagePosition.x += framePositionArray[4].x - imagePositionArray[4].x
                            // print("중간우측")
                        }
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
                                  rectangleSize: gemotry.size,
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
                        
                        let framePositionArray = cutImageManager.positionArray(center: newLocation, width: newSize.width, height: newSize.height)
                        let imagePositionArray = cutImageManager.positionArray(center: imagePosition, width: originalImageSize.width * zoomScale, height: originalImageSize.height * zoomScale)
                        
                        switch selectionFrameRectangle.location{
                        case .lt:
                            if framePositionArray[0].x < imagePositionArray[0].x { // 좌상단
                                newSize.width = gemotry.size.width - (imagePositionArray[0].x * 2)
                                newLocation.x = viewCenter.x
                            }
                            if framePositionArray[0].y < imagePositionArray[0].y {
                                newSize.height = gemotry.size.height - (imagePositionArray[0].y * 2)
                                newLocation.y = viewCenter.y
                            }
                        case .tt:
                            if framePositionArray[2].x > imagePositionArray[2].x { // 우상단
                                newSize.width = gemotry.size.width - (gemotry.size.width - imagePositionArray[2].x) * 2
                                newLocation.x = viewCenter.x
                            }
                            if framePositionArray[2].y < imagePositionArray[2].y {
                                newSize.height = gemotry.size.height - (imagePositionArray[2].y * 2)
                                newLocation.y = viewCenter.y
                            }
                        case .t:
                            if framePositionArray[1].y < imagePositionArray[1].y { // 상단
                                newSize.height = frameHeight
                                newLocation.y = frameLocation.y
                            }
                        case .lb:
                            if framePositionArray[5].x < imagePositionArray[5].x{ // 좌하단
                                newSize.width = gemotry.size.width - (imagePositionArray[5].x * 2)
                                newLocation.x = viewCenter.x
                            }
                            if framePositionArray[5].y > imagePositionArray[5].y {
                                newSize.height = gemotry.size.height - (gemotry.size.height - imagePositionArray[5].y) * 2
                                newLocation.y = viewCenter.y
                            }
                        case .tb:
                            if framePositionArray[7].x > imagePositionArray[7].x{ // 우하단
                                newSize.width = gemotry.size.width - (gemotry.size.width - imagePositionArray[7].x) * 2
                                newLocation.x = viewCenter.x
                            }
                            if framePositionArray[7].y > imagePositionArray[7].y {
                                newSize.height = gemotry.size.height - (gemotry.size.height - imagePositionArray[7].y) * 2
                                newLocation.y = viewCenter.y
                            }
                        case .b:
                            if framePositionArray[6].y > imagePositionArray[6].y { // 하단
                                newSize.height = frameHeight
                                newLocation.y = frameLocation.y
                            }
                        case .lc:
                            if framePositionArray[3].x < imagePositionArray[3].x { // 중간 좌측
                                newSize.width = frameWidth
                                newLocation.x = frameLocation.x
                            }
                        case .tc:
                            if framePositionArray[4].x > imagePositionArray[4].x { // 중간 우측
                                newSize.width = frameWidth
                                newLocation.x = frameLocation.x
                            }
                        }
                        
                        let minimumSize = CGSize(width: viewWidth * 0.2, height: viewWidth * 0.2)
                        
                        
                        if newSize.width < minimumSize.width {
                            return
                        }
                        
                        if newSize.height < minimumSize.height {
                            return
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
                    .position(frameLocation)
            }
            .frame(width: gemotry.size.width, height: gemotry.size.height)
            .background(.clear)
            .onAppear(perform: {
                imagePosition = viewCenter
                lastImagePosition = imagePosition
                
                frameLocation = viewCenter
                maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                
                originalImageSize = CGSizeMake(frameWidth, frameHeight)
                previousFrameSize = CGSizeMake(frameWidth, frameHeight)
            })
        }
    }
}
