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
    @State private var originalImageSize: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    @State private var previousFrameSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let padding = cutImageManager.padding
            let selectionFrameLineWidth: CGFloat = cutImageManager.frameRectangleLineWidth
            let viewWidth = geometry.size.width - padding
            let viewHeight = geometry.size.height - padding
            
            let viewCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let lineSize = CGSize(width: 4, height: 20)
            
            ZStack{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(zoomScale)
                    .scaleEffect(x: cutImageManager.currentFlipHorizontal.x, y: cutImageManager.currentFlipHorizontal.y)
                    .rotationEffect(.degrees(cutImageManager.currentDegree))
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
                        // 최소 줌을 frameWidth / frameHeight 에 맞게 설정함
                        applyMinimumZoomScale(frameWidth: frameWidth, frameHeight: frameHeight)
                        lastZoomScale = zoomScale
                        updateImagePosition()
                    }
                    .onReceive(cutImageManager.imageDrag){ value in
                        let newPositionX = lastImagePosition.x + value.x
                        let newPositionY = lastImagePosition.y + value.y
                        // frameWidth 넘게 drag 되지 않게
                        if frameLocation.x - frameWidth / 2 < newPositionX - (originalImageSize.width * zoomScale / 2){
                            imagePosition.x = frameLocation.x + (originalImageSize.width * zoomScale - frameWidth) / 2
                        } else if frameLocation.x + frameWidth / 2 > newPositionX + (originalImageSize.width * zoomScale / 2){
                            imagePosition.x = frameLocation.x - (originalImageSize.width * zoomScale - frameWidth) / 2
                        } else {
                            imagePosition.x = newPositionX
                        }
                        // FrameHeight 넘게 Drag 되지 않게
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
                    .onReceive(cutImageManager.rotateDegreeTapped){ _ in
                        cutImageManager.rotateDegree()
                        
                        var newFrameWidth = frameHeight
                        var newFrameHeight = frameWidth
                        // FrameWIdth 뷰사이즈에 맞게 조정
                        if newFrameWidth > newFrameHeight{
                            newFrameHeight = min(viewWidth * frameWidth / frameHeight, viewHeight)
                            newFrameWidth = newFrameHeight * frameHeight / frameWidth
                        } else {
                            newFrameWidth = min(viewHeight * frameHeight / frameWidth, viewWidth)
                            newFrameHeight = newFrameWidth * frameWidth / frameHeight
                        }
                        
                        // applyMinimumZoomScale(frameWidth: newFrameWidth, frameHeight: newFrameHeight)
                        
                        frameWidth = newFrameWidth
                        frameHeight = newFrameHeight
                        previousFrameSize = CGSize(width: frameWidth, height: frameHeight)
                        maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)

                        // image는 원래 세로로 고정되어있고 rotation 값만 수정하는 경우라
                        // -90 , -270도에선 이미지 비율을 가로 세로 바꿔야됨
                        let previousImageSize = imageSize
                        if cutImageManager.isHorizontalDegree(){
                            var newImageWidth = imageSize.height
                            var newImageHeight = imageSize.width
                            if newImageWidth > newImageHeight {
                                newImageWidth = viewWidth
                                newImageHeight = newImageWidth * imageSize.width / imageSize.height
                            } else {
                                newImageHeight = viewHeight
                                newImageWidth = newImageHeight * imageSize.height / imageSize.width
                            }
                            imageSize.width = newImageHeight
                            imageSize.height = newImageWidth
                        } else {
                            var newImageWidth: CGFloat = imageSize.width
                            var newImageHeight: CGFloat = imageSize.height
                            if newImageWidth > newImageHeight {
                                newImageWidth = viewWidth
                                newImageHeight = newImageWidth * imageSize.height / imageSize.width
                            } else {
                                newImageHeight = viewHeight
                                newImageWidth = newImageHeight * imageSize.width / imageSize.height
                            }
                            imageSize.width = newImageWidth
                            imageSize.height = newImageHeight
                        }
                        // originalImage는 화면에 보여지는 image 크기 그대로임
                        originalImageSize.width = cutImageManager.isHorizontalDegree() ? imageSize.height : imageSize.width
                        originalImageSize.height = cutImageManager.isHorizontalDegree() ? imageSize.width : imageSize.height
                        
                        // 회전할때 이미지 위치 재설정
                        if imagePosition != viewCenter{
                            // 1. 이미지 크기가 변하고 난 후의 frameLocation 좌표를 구함
                            let originalXPoint: CGFloat = imagePosition.x + (frameLocation.x - imagePosition.x) * (imageSize.width / previousImageSize.width)
                            let originalYPoint: CGFloat = imagePosition.y +  (frameLocation.y - imagePosition.y) * (imageSize.height / previousImageSize.height)
                            let originalPoint = CGPoint(x: originalXPoint,y: originalYPoint)
                            let centerPoint = imagePosition
                            // 2. 1번좌표를 imagePosition을 중심으로 -90도로 회전했을때의 좌표를 구함
                            let rotatedPoint = rotateUsingCGAffineTransform(point: originalPoint, center: centerPoint, angle: -90)
                            // 3. frameLocation과 2번좌표의 변화값을 구해서 imagePosition을 이동시킨다
                            imagePosition.x += frameLocation.x - rotatedPoint.x
                            imagePosition.y += frameLocation.y - rotatedPoint.y
                            
                            lastImagePosition = imagePosition
                        }
                    }
                    .frame(width: imageSize.width, height: imageSize.height)
                    .position(imagePosition)
                    .clipped()
                
                MaskRectangleView(overlayColor: UIColor.black.withAlphaComponent(0.3),
                                  rectangleSize: geometry.size,
                                  maskRectangleSize: CGSize(width: frameWidth, height: frameHeight),
                                  maskPosition: CGPoint(x: maskRectangleViewLocation.x, y: maskRectangleViewLocation.y))
                SelectionFrameView(imageWidth: frameWidth, imageHeight: frameHeight , rectangleLineWidth: selectionFrameLineWidth, lineSize: lineSize, cutImageManager: cutImageManager)
                    .frame(width: frameWidth + padding, height: frameHeight + padding)
                    .onReceive(cutImageManager.selectionFrameDrag){ data in
                        let currentSize = CGSize(width: frameWidth, height: frameHeight)
                        let selectionFrameRectangle = data.selectionFrameRectangle
                        var newSize = CGSize(width: data.position.x, height: data.position.y)
                        let scale = data.selectionFrameRectangle.scale
                        var newLocation: CGPoint = frameLocation
                        let location = selectionFrameRectangle.location
                        switch location{
                        case .lt:
                            // (0,0)에서 시작되기때문에 드래그한 값 = 이동량
                            let widthDifferenceValue = newSize.width
                            let heightDifferenceValue = newSize.height
                            newSize = CGSize(width: currentSize.width - widthDifferenceValue, height: currentSize.height - heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .tt:
                            let widthDifferenceValue = (newSize.width - currentSize.width)
                            let heightDifferenceValue = newSize.height
                            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height - heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .lb:
                            let widthDifferenceValue = newSize.width
                            let heightDifferenceValue = (newSize.height - currentSize.height)
                            newSize = CGSize(width: currentSize.width - widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                            newLocation = CGPoint(x: frameLocation.x + widthDifferenceValue / 2, y: frameLocation.y + heightDifferenceValue / 2)
                        case .tb:
                            let widthDifferenceValue = (newSize.width - currentSize.width)
                            let heightDifferenceValue = (newSize.height - currentSize.height)
                            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
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
                        
                        let newFrame = cutImageManager.adjustFrameToImageSize(newSize: newSize, newLocation: newLocation,
                                                                              viewSize: geometry.size,
                                                                              previousFrameSize: previousFrameSize,
                                                                              frameLocation: frameLocation,
                                                                              frameSize: CGSize(width: frameWidth, height: frameHeight),
                                                                              originalImageSize: originalImageSize,
                                                                              imagePosition: imagePosition,
                                                                              zoomScale: zoomScale,
                                                                              padding: padding, 
                                                                              location: location)
                        
                        if let newFrame = newFrame{
                            self.frameWidth = newFrame.size.width
                            self.frameHeight = newFrame.size.height
                            self.frameLocation = newFrame.location
                            maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                        }
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
                                imageScale = newFrameHeight / frameHeight
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
                                ; imagePosition.x = newImageCenter.x + (newPosition.x - currentPosition.x)
                                imagePosition.y = newImageCenter.y + (newPosition.y - currentPosition.y)
                            }
                            
                            zoomScale *= imageScale
                            lastZoomScale = zoomScale
                            
                            frameWidth = newFrameWidth
                            frameHeight = newFrameHeight
                            previousFrameSize = CGSize(width: newFrameWidth, height: newFrameHeight)
                            lastImagePosition = imagePosition
                            maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                        
                            updateImagePosition()
                        }
                    }
                    .onReceive(cutImageManager.frameRatioTapped){ ratio in
                        var newFrameWidth = frameWidth
                        var newFrameHeight = frameHeight
                        
                        if originalImageSize.width > originalImageSize.height{
                            newFrameHeight = min(viewWidth * ratio.heightRatio / ratio.widthRatio, viewHeight)
                            newFrameWidth = newFrameHeight * ratio.widthRatio / ratio.heightRatio
                        } else {
                            newFrameWidth = min(viewHeight * ratio.widthRatio / ratio.heightRatio, viewWidth)
                            newFrameHeight = newFrameWidth * ratio.heightRatio / ratio.widthRatio
                        }

                        applyMinimumZoomScale(frameWidth: newFrameWidth, frameHeight: newFrameHeight)

                        frameWidth = newFrameWidth
                        frameHeight = newFrameHeight
                        previousFrameSize = CGSize(width: newFrameWidth, height: newFrameHeight)
                        maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                        
                        updateImagePosition()
                    }
                    .position(frameLocation)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(.clear)
            .onAppear(perform: {
                imagePosition = cutImageManager.imagePosition
                lastImagePosition = imagePosition
                
                frameLocation = viewCenter
                maskRectangleViewLocation = CGPoint(x: frameLocation.x - frameWidth / 2, y: frameLocation.y - frameHeight / 2)
                
                originalImageSize = cutImageManager.originalImageSize
                previousFrameSize = CGSize(width: frameWidth, height: frameHeight)
                imageSize = cutImageManager.imageSize
                
                zoomScale = cutImageManager.zoomScale
                lastZoomScale = cutImageManager.zoomScale
                
                if cutImageManager.imageRatio == .zero{
                    if let imageRatio = cutImageManager.reduceFraction(numerator: Int(frameWidth), denominator: Int(frameHeight)){
                        cutImageManager.imageRatio = CGSize(width: imageRatio.0, height: imageRatio.1)
                    }
                }
            })
            .onDisappear{
                initImageInfo()
            }
            .onReceive(NotificationCenter.default.publisher(for: .saveImageInfo)) { notification in
                initImageInfo()
                cutImageManager.completeSaveImageInfo.send()
            }
        }
    }
    
    private func initImageInfo(){
        cutImageManager.frameWidth = frameWidth
        cutImageManager.frameHeight = frameHeight
        cutImageManager.imagePosition = imagePosition
        cutImageManager.zoomScale = zoomScale
        cutImageManager.originalImageSize = originalImageSize
        cutImageManager.imageSize = imageSize
    }
    
    private func updateImagePosition(){
        let framePositionArray = cutImageManager.positionArray(center: frameLocation, width: frameWidth, height: frameHeight)
        let imagePositionArray = cutImageManager.positionArray(center: imagePosition, width: originalImageSize.width * zoomScale, height: originalImageSize.height * zoomScale)
        
        // Selectionframe과 공간이 생길 때 frame이에 맞게 position 옮겨주는 작업
        imagePosition = cutImageManager.updateImagePosition(framePositionArray: framePositionArray,
                                                            imagePositionArray: imagePositionArray,
                                                            imagePosition: imagePosition)
    }
    
    private func applyMinimumZoomScale(frameWidth: CGFloat, frameHeight: CGFloat){
        if zoomScale * originalImageSize.width < frameWidth{
            zoomScale *= frameWidth / (zoomScale * originalImageSize.width)
        }
        if zoomScale * originalImageSize.height < frameHeight {
            zoomScale *= frameHeight / (zoomScale * originalImageSize.height)
        }
    }
    
    func rotateUsingCGAffineTransform(point: CGPoint, center: CGPoint, angle: CGFloat) -> CGPoint {
        // 기준점 이동
        let translatedPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        
        // 회전 변환 생성 (각도는 라디안으로 제공)
        let radians = angle * .pi / 180
        let rotation = CGAffineTransform(rotationAngle: radians)
        
        // 회전 적용
        let rotatedPoint = translatedPoint.applying(rotation)
        
        // 기준점 복원
        return CGPoint(x: rotatedPoint.x + center.x, y: rotatedPoint.y + center.y)
    }
}
