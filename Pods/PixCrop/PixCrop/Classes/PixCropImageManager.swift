//
//  PixCropImageManager.swift
//  Pods
//
//  Created by 홍승아 on 1/31/25.
//

import Foundation

class PixCropImageManager{
    
    func dragImage(translation: CGPoint, viewSize: CGSize){
        var newCenter = CGPoint(
            x: PixCropImage.lastCenter.x + translation.x,
            y: PixCropImage.lastCenter.y + translation.y
        )
        let viewCenter = LayoutUtils.center(for: viewSize)
        
        let frameLeadingX = PixCropFrame.position(for: .centerLeading, PixCropFrame.size, viewCenter).x
        let frameTrailingX = PixCropFrame.position(for: .centerTrailing, PixCropFrame.size, viewCenter).x
        let frameTopY = PixCropFrame.position(for: .top, PixCropFrame.size, viewCenter).y
        let frameBottomY = PixCropFrame.position(for: .bottom, PixCropFrame.size, viewCenter).y
        
        let halfImageWidth = PixCropImage.size.width * PixCropImage.zoomScale / 2
        let halfImageHeight = PixCropImage.size.height * PixCropImage.zoomScale / 2
        
        // X 좌표 제한
        newCenter.x = min(newCenter.x, frameLeadingX + halfImageWidth)
        newCenter.x = max(newCenter.x, frameTrailingX - halfImageWidth)
        
        // Y 좌표 제한
        newCenter.y = min(newCenter.y, frameTopY + halfImageHeight)
        newCenter.y = max(newCenter.y, frameBottomY - halfImageHeight)
        
        PixCropImage.update(center: newCenter)
    }
    
    func dragImageEnded(){
        PixCropImage.update(center: PixCropImage.center, updateLast: true)
    }
    
    func zoomImage(scale: CGFloat){
        let minScale: CGFloat = max(PixCropFrame.size.width / PixCropImage.size.width, PixCropFrame.size.height / PixCropImage.size.height)
        let maxScale: CGFloat = minScale * PixCropImage.maxZoomScale
        PixCropImage.zoomScale = min(max(minScale, PixCropImage.lastZoomScale * scale), maxScale)
    }
    
    func zoomImageEnded(){
        LocationType.allCases.forEach{ locationType in
            updateImageCenter(by: locationType)
        }
        PixCropImage.lastZoomScale = PixCropImage.zoomScale
    }
    
    func ratio(){
        let originalImageSize = PixCropImage.size
        let frameSize = PixCropFrame.size
        var zoomScale = PixCropImage.zoomScale
        
        if originalImageSize.width * zoomScale < frameSize.width{
            zoomScale *= frameSize.width / (zoomScale * originalImageSize.width)
        }
        if originalImageSize.height * zoomScale < frameSize.height {
            zoomScale *= frameSize.height / (zoomScale * originalImageSize.height)
        }
        
        PixCropImage.zoomScale = zoomScale
        
        LocationType.allCases.forEach{ locationType in
            updateImageCenter(by: locationType)
        }
    }
    
    private func updateImageCenter(by locationType: LocationType){
        let framePosition = PixCropFrame.position(for: locationType)
        let imagePosition = PixCropImage.position(for: locationType)
        
        if (locationType.isLeading && framePosition.x < imagePosition.x) || (locationType.isTrailing && framePosition.x > imagePosition.x){
            PixCropImage.center.x += framePosition.x - imagePosition.x
        }
        
        if (locationType.isTop && framePosition.y < imagePosition.y) || (locationType.isBottom && framePosition.y > imagePosition.y){
            PixCropImage.center.y += framePosition.y - imagePosition.y
        }
    }
}

extension PixCropImageManager{
    private func rotateUsingCGAffineTransform(point: CGPoint, center: CGPoint, angle: CGFloat) -> CGPoint {
        let translatedPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        
        let radians = angle * .pi / 180
        let rotation = CGAffineTransform(rotationAngle: radians)
        
        let rotatedPoint = translatedPoint.applying(rotation)
        
        return CGPoint(x: rotatedPoint.x + center.x, y: rotatedPoint.y + center.y)
    }
    
    func rotate(by degrees: Int) {
        PixCropImage.degree = degrees
    }
    
    func rotate(viewSize: CGSize, viewSizeWithoutPadding: CGSize, direction: PixCropRotateDirection){
        let viewCenter = LayoutUtils.center(for: viewSize)
        
        /* 프레임 크기 변환 */
        let lastFrameSize = PixCropFrame.size
        let newFrameSize = LayoutUtils.scaledSizeToFit(size: CGSize(width: PixCropFrame.size.height, height: PixCropFrame.size.width), viewSize: viewSizeWithoutPadding)
        PixCropFrame.update(size: newFrameSize, center: viewCenter, updateLast: true)
        
        /* 이미지 회전 */
        PixCropImage.rotate(direction)
        PixCropImage.swapTransform(PixCropImage.transformScale)
        
        /* 이미지 크기 변환 */
        let rotateDegree: CGFloat = direction == .left ? -90 : 90
        let lastImageSize = PixCropImage.size
        let lastZoomScale = PixCropImage.zoomScale
        var imageCenter = PixCropImage.center
        let swapImageSize = LayoutUtils.scaledSizeToFit(size: CGSize(width: PixCropImage.size.height, height: PixCropImage.size.width), viewSize: viewSizeWithoutPadding)
        let newImageWidth = swapImageSize.width
        let newImageHeight = swapImageSize.height
        let lastOriginalSize = PixCropImage.originalSize
        let newOriginalSize = CGSize(
            width: PixCropImage.isHorizontalDegree() ? newImageWidth : newImageHeight,
            height: PixCropImage.isHorizontalDegree() ? newImageHeight : newImageWidth
        )
        
        /* 이미지 scale 변환 */
        let newScale = lastFrameSize.width / (lastOriginalSize.width * PixCropImage.zoomScale)
        let newZoomScale = newFrameSize.height / (newOriginalSize.width * newScale)
   
        /* 이미지 center 변환 */
        // 1. newImage 크기를 반영한 frameCenter를 구한다.
        let newFrameCenterX = imageCenter.x + (viewCenter.x - imageCenter.x) * ((newImageHeight * newZoomScale) / (lastImageSize.width * lastZoomScale))
        let newFrameCenterY = imageCenter.y + (viewCenter.y - imageCenter.y) * ((newImageWidth * newZoomScale) / (lastImageSize.height * lastZoomScale))
        // 2. 1번 좌표를 imageCenter 기준으로 n도 회전환 좌표를 구한다.
        let rotatePosition = rotateUsingCGAffineTransform(point: CGPoint(x: newFrameCenterX, y: newFrameCenterY), center: imageCenter, angle: rotateDegree)
        // 3. 최종적으로 viewCenter와 rotatePosition의 차잇값을 구한다.
        imageCenter.x += viewCenter.x - rotatePosition.x
        imageCenter.y += viewCenter.y - rotatePosition.y
        
        /* 이미지 변경사항 적용 */
        PixCropImage.size = CGSize(width: newImageWidth, height: newImageHeight)
        PixCropImage.originalSize = newOriginalSize
        PixCropImage.zoomScale = max(1,newZoomScale)
        PixCropImage.update(center: imageCenter, updateLast: true)
    }
    
    func flipHorizontally(viewCenter: CGPoint) {
        let imageTopLeading = PixCropImage.position(for: .topLeading)
        let imageTopTrailing = PixCropImage.position(for: .topTrailing)
        var newImageCenter = PixCropImage.center

        if newImageCenter.x != viewCenter.x{
            newImageCenter.x -= imageTopTrailing.x - (viewCenter.x + (viewCenter.x - imageTopLeading.x))
        }
        
        PixCropImage.update(center: newImageCenter, updateLast: true)
        PixCropImage.flipHorizontally()
    }
    
    func flipVertically(viewCenter: CGPoint) {
        let imageTop = PixCropImage.position(for: .top)
        let imageBottom = PixCropImage.position(for: .bottom)
        var newImageCenter = PixCropImage.center

        if newImageCenter.y != viewCenter.y{
            newImageCenter.y -= imageBottom.y - (viewCenter.y + (viewCenter.y - imageTop.y))
        }
        
        PixCropImage.update(center: newImageCenter, updateLast: true)
        PixCropImage.flipVertically()
    }
}
