//
//  CutImageManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/6/24.
//

import SwiftUI
import Combine

struct FrameRatio: Hashable{
    var widthRatio: CGFloat
    var heightRatio: CGFloat
    var string: String{
        return "\(Int(widthRatio)) : \(Int(heightRatio))"
    }
}

struct NewFrame{
    var size: CGSize
    var location: CGPoint
}

enum RatioDirection{
    case horizontal, vertical
}

class CutImageManager: ObservableObject{
    var selectionFrameDrag = PassthroughSubject<SelectionFrameRectangleData, Never>()
    var selectionFrameDragEnded = PassthroughSubject<SelectionFrameRectangleData, Never>()
    var completeSaveImageInfo = PassthroughSubject<Void, Never>()
    
    var imageZoom = PassthroughSubject<CGFloat, Never>()
    var imageZoomEnded = PassthroughSubject<Void, Never>()
    var imageDrag = PassthroughSubject<CGPoint, Never>()
    var imageDragEnded = PassthroughSubject<CGPoint, Never>()
    var frameRatioTapped = PassthroughSubject<FrameRatio, Never>()
    var rotateDegreeTapped = PassthroughSubject<Void, Never>()
    
    @Published var imageRatio: CGSize = .zero {
        didSet{
            ratioArray = [
                FrameRatio(widthRatio: imageRatio.width, heightRatio: imageRatio.height),
                frameRatio(aspectRatio: CGSize(width: 1, height: 1)),
                frameRatio(aspectRatio: CGSize(width: 9, height: 16)),
                frameRatio(aspectRatio: CGSize(width: 4, height: 5)),
                frameRatio(aspectRatio: CGSize(width: 5, height: 7)),
                frameRatio(aspectRatio: CGSize(width: 3, height: 4)),
                frameRatio(aspectRatio: CGSize(width: 3, height: 5)),
                frameRatio(aspectRatio: CGSize(width: 2, height: 3)),
            ]
        }
    }
    @Published var currentRatioDirection: RatioDirection = .horizontal
    @Published var currentFlipHorizontal: CGPoint = CGPoint(x: 1, y: 1)
    @Published var currentDegree: CGFloat = .zero
    
    @Published var frameWidth: CGFloat = .zero
    @Published var frameHeight: CGFloat = .zero
    @Published var imagePosition: CGPoint = .zero
    @Published var zoomScale: CGFloat = 1.0
    @Published var originalImageSize: CGSize = .zero
    @Published var imageSize: CGSize = .zero
    @Published var centerLocation: CGPoint = .zero
    
    var ratioArray: [FrameRatio] = []
    
    let padding: CGFloat = 15
    let frameRectangleLineWidth: CGFloat = 1
    
    var editImageViewSize: CGSize = .zero
    
    func initFrameSize(_ size: CGSize){
        frameWidth = size.width
        frameHeight = size.height
        originalImageSize = size
        imageSize = size
    }
    
    func flipHorizontalToggle(){
        currentFlipHorizontal.x *= -1
    }
    
    func rotateDegree(){
        currentDegree -= 90
        if currentDegree < -360{
            currentDegree = -90
        }
        currentRatioDirection = isHorizontalDegree() ? .horizontal : .vertical
        
        let originRatio: FrameRatio = FrameRatio(widthRatio: ratioArray[0].widthRatio, heightRatio: ratioArray[0].heightRatio)
        ratioArray[0].widthRatio = originRatio.heightRatio
        ratioArray[0].heightRatio = originRatio.widthRatio
    }
    
    func isHorizontalDegree() -> Bool{
        return currentDegree == -90 || currentDegree == -270
    }
    
    func ratioDriectionToggle(){
        currentRatioDirection = currentRatioDirection == .horizontal ? .vertical : .horizontal
    }
    
    func frameRatio(aspectRatio: CGSize) -> FrameRatio{
        if currentRatioDirection == .horizontal{
            return FrameRatio(widthRatio: max(aspectRatio.width, aspectRatio.height), heightRatio: min(aspectRatio.width, aspectRatio.height))
        } else {
            return FrameRatio(widthRatio: min(aspectRatio.width, aspectRatio.height), heightRatio: max(aspectRatio.width, aspectRatio.height))
        }
    }
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        return b == 0 ? a : gcd(b, a % b)
    }
    
    // 분수를 약분하는 함수
    func reduceFraction(numerator: Int, denominator: Int) -> (Int, Int)? {
        guard denominator != 0 else {
            return nil  // 분모가 0이면 에러 처리
        }
        
        let divisor = gcd(numerator, denominator)
        return (numerator / divisor, denominator / divisor)
    }
    
    func positionArray(center: CGPoint, width: CGFloat, height: CGFloat) -> [CGPoint]{
        let halfWidth = width / 2
        let halfHeight = height / 2
        
        let result = SelectionFrameRectangle.Location.allCases.map{ location in
            let data = SelectionFrameRectangle(location: location)
            return CGPoint(x: center.x + halfWidth * data.scale.x, y: center.y + halfHeight * data.scale.y)
        }
        
        return result
    }
    
    func updateImagePosition(framePositionArray: [CGPoint], imagePositionArray: [CGPoint], imagePosition: CGPoint) -> CGPoint {
        var resultPosition = imagePosition
        // 비교 순서
        // (좌상단 = 우상단 > 상단) = (좌하단 = 우하단 > 하단) > (중간좌측 = 중간 우측)
        if framePositionArray[0].x < imagePositionArray[0].x && framePositionArray[0].y < imagePositionArray[0].y{ // 좌상단 빌 때
            resultPosition.x += framePositionArray[0].x - imagePositionArray[0].x
            resultPosition.y += framePositionArray[0].y - imagePositionArray[0].y
            // print("좌상단")
        } else if framePositionArray[2].x > imagePositionArray[2].x && framePositionArray[2].y < imagePositionArray[2].y { // 우상단
            resultPosition.x += framePositionArray[2].x - imagePositionArray[2].x
            resultPosition.y += framePositionArray[2].y - imagePositionArray[2].y
            // print("우상단")
        } else if framePositionArray[1].y < imagePositionArray[1].y { // 상단
            resultPosition.y += framePositionArray[1].y - imagePositionArray[1].y
            // print("상단")
        } else if framePositionArray[5].x < imagePositionArray[5].x && framePositionArray[5].y > imagePositionArray[5].y { // 좌하단
            resultPosition.x += framePositionArray[5].x - imagePositionArray[5].x
            resultPosition.y += framePositionArray[5].y - imagePositionArray[5].y
           // print("좌하단")
        } else if framePositionArray[7].x > imagePositionArray[7].x && framePositionArray[7].y > imagePositionArray[7].y { // 우하단
            resultPosition.x += framePositionArray[7].x - imagePositionArray[7].x
            resultPosition.y += framePositionArray[7].y - imagePositionArray[7].y
            // print("우하단")
        } else if framePositionArray[6].y > imagePositionArray[6].y { // 하단
            resultPosition.y += framePositionArray[6].y - imagePositionArray[6].y
            // print("하단")
        } else if framePositionArray[3].x < imagePositionArray[3].x { // 중간 좌측
            resultPosition.x += framePositionArray[3].x - imagePositionArray[3].x
            // print("중간좌측")
        } else if framePositionArray[4].x > imagePositionArray[4].x { // 중간 우측
            resultPosition.x += framePositionArray[4].x - imagePositionArray[4].x
            // print("중간우측")
        }
        
        return resultPosition
    }
    
    func resizeFrameToFitImage(previousFramePositionArray: [CGPoint], framePositionArray: [CGPoint], imagePositionArray: [CGPoint], viewWidth: CGFloat, viewHeight: CGFloat, viewCenter: CGPoint, newSize: CGSize, newLocation: CGPoint, framePosition: CGPoint, frameWidth: CGFloat, frameHeight: CGFloat, location: SelectionFrameRectangle.Location) -> (CGSize, CGPoint){
        var newSize = newSize
        var newLocation = newLocation
        
        switch location{
            case .lt:
                if framePositionArray[0].x < imagePositionArray[0].x { // 좌상단
                    newSize.width = viewWidth - (imagePositionArray[0].x * 2)
                    newLocation.x = viewCenter.x
                }
                if framePositionArray[0].y < imagePositionArray[0].y {
                    newSize.height = viewHeight - (imagePositionArray[0].y * 2)
                    newLocation.y = viewCenter.y
                }
            case .tt:
                if framePositionArray[2].x > imagePositionArray[2].x { // 우상단
                    newSize.width = viewWidth - (viewWidth - imagePositionArray[2].x) * 2
                    newLocation.x = viewCenter.x
                }
                if framePositionArray[2].y < imagePositionArray[2].y {
                    newSize.height = viewHeight - (imagePositionArray[2].y * 2)
                    newLocation.y = viewCenter.y
                }
            case .lb:
                if framePositionArray[5].x < imagePositionArray[5].x{ // 좌하단
                    newSize.width = viewWidth - (imagePositionArray[5].x * 2)
                    newLocation.x = viewCenter.x
                }
                if framePositionArray[5].y > imagePositionArray[5].y {
                    newSize.height = viewHeight - (viewHeight - imagePositionArray[5].y) * 2
                    newLocation.y = viewCenter.y
                }
            case .tb:
                if framePositionArray[7].x > imagePositionArray[7].x{ // 우하단
                    newSize.width = viewWidth - (viewWidth - imagePositionArray[7].x) * 2
                    newLocation.x = viewCenter.x
                }
                if framePositionArray[7].y > imagePositionArray[7].y {
                    newSize.height = viewHeight - (viewHeight - imagePositionArray[7].y) * 2
                    newLocation.y = viewCenter.y
                }
            case .t:
                if framePositionArray[1].y < imagePositionArray[1].y { // 상단
                    newSize.height = previousFramePositionArray[6].y - imagePositionArray[1].y
                    newLocation.y = framePosition.y - (newSize.height - frameHeight) / 2
                }
            case .b:
                if framePositionArray[6].y > imagePositionArray[6].y { // 하단
                    newSize.height = imagePositionArray[6].y - previousFramePositionArray[1].y
                    newLocation.y = framePosition.y + (newSize.height - frameHeight) / 2
                }
            case .lc:
                if framePositionArray[3].x < imagePositionArray[3].x { // 중간 좌측
                    newSize.width = previousFramePositionArray[4].x - imagePositionArray[3].x
                    newLocation.x = framePosition.x - (newSize.width - frameWidth) / 2
                }
            case .tc:
                if framePositionArray[4].x > imagePositionArray[4].x { // 중간 우측
                    newSize.width = imagePositionArray[4].x - previousFramePositionArray[3].x
                    newLocation.x = framePosition.x + (newSize.width - frameWidth) / 2
                }
            }
        
        return (newSize, newLocation)
    }
    
    func adjustFrameToImageSize(newSize: CGSize, newLocation: CGPoint, viewSize: CGSize, previousFrameSize: CGSize, frameLocation: CGPoint, frameSize: CGSize, originalImageSize: CGSize, imagePosition: CGPoint, zoomScale: CGFloat, padding: CGFloat, location: SelectionFrameRectangle.Location) -> NewFrame? {
        let viewCenter: CGPoint = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        let previousFramePositionArray = positionArray(center: viewCenter, width: previousFrameSize.width, height: previousFrameSize.height)
        let framePositionArray = positionArray(center: newLocation, width: newSize.width, height: newSize.height)
        let imagePositionArray = positionArray(center: imagePosition, width: originalImageSize.width * zoomScale, height: originalImageSize.height * zoomScale)
        
        var newSize = newSize
        var newLocation = newLocation
        let frameWidth = frameSize.width
        let frameHeight = frameSize.height
        let viewWidth = viewSize.width
        let viewHeight = viewSize.height
        
        // frame이 이미지 사이즈 넘어가지 않도록 조정하는 작업
        let updateData = resizeFrameToFitImage(
            previousFramePositionArray: previousFramePositionArray,
            framePositionArray: framePositionArray,
            imagePositionArray: imagePositionArray,
            viewWidth: viewSize.width, viewHeight: viewSize.height,
            viewCenter: viewCenter,
            newSize: newSize, newLocation: newLocation,
            framePosition: frameLocation,
            frameWidth: frameWidth,
            frameHeight: frameHeight, 
            location: location)
        newSize = updateData.0
        newLocation = updateData.1
        
        let minimumSize = CGSize(width: viewWidth * 0.2, height: viewWidth * 0.2)
        // 조건 1. 최소 사이즈보다 작아지지 않을 것
        if newSize.width < minimumSize.width || newSize.height < minimumSize.height{
            return nil
        }
        // 조건 2. Frame이 viewSize를 넘어가지 말 것
        if newLocation.x - (newSize.width / 2) < padding / 2 {
            if location == .lt || location == .lc || location == .lb{
                newSize.width = previousFramePositionArray[4].x - padding / 2
                newLocation.x = frameLocation.x + (newSize.width - frameWidth) / 2
            }
        } else if newLocation.x + (newSize.width / 2) > viewWidth - padding / 2 {
            if location == .tt || location == .tc || location == .tb{
                newSize.width =  viewWidth - padding / 2 - previousFramePositionArray[3].x
                newLocation.x = frameLocation.x - (newSize.width - frameWidth) / 2
            }
        } else if newLocation.y - (newSize.height / 2) < padding / 2 {
            if location == .t || location == .lt || location == .tt{
                newSize.height = viewHeight - padding / 2 - previousFramePositionArray[1].y
                newLocation.y = frameLocation.y - (newSize.height - frameHeight) / 2
            }
        } else if newLocation.y + (newSize.height / 2) > viewHeight - padding / 2 {
            if location == .b || location == .lb || location == .tb{
                newSize.height = previousFramePositionArray[6].y - padding / 2
                newLocation.y = frameLocation.y + (newSize.height - frameHeight) / 2
            }
        }
        return NewFrame(size: newSize, location: newLocation)
    }
    
    func imageSize(imageSize: CGSize, viewSize: CGSize) -> CGSize{
        let widthRatio = viewSize.width / imageSize.width
        let heightRatio = viewSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        return CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
    }
    
    func paddingImageSize(imageSize: CGSize, multiple: CGFloat) -> CGSize{
        var size: CGSize = .zero
        if imageSize.width > imageSize.height {
            let newImageWidth: CGFloat = imageSize.width + padding * multiple
            size = CGSize(width: newImageWidth, height: imageSize.height * newImageWidth / imageSize.width)
        } else {
            let newImageHeight: CGFloat = imageSize.height + padding * multiple
            size = CGSize(width: imageSize.width * newImageHeight / imageSize.height, height: newImageHeight)
        }
        return size
    }
    
    func editImagePositionArray() -> [CGPoint]{
        let imageSize = paddingImageSize(imageSize: CGSize(width: frameWidth, height: frameHeight), multiple: 1.0)
        let leadingTopPosition = CGPoint(x: (editImageViewSize.width / 2) - (imageSize.width / 2), y: (editImageViewSize.height / 2) - (imageSize.height / 2))
        let trailingBottomPosition = CGPoint(x: (editImageViewSize.width / 2) + (imageSize.width / 2), y: (editImageViewSize.height / 2) + (imageSize.height / 2))
        return [leadingTopPosition, trailingBottomPosition]
    }
    
    func imageSizeWithDegree(imageSize: CGSize, viewSize: CGSize) -> CGSize{
        if isHorizontalDegree(){
            if imageSize.width > imageSize.height{
                return CGSize(width: viewSize.height, height: imageSize.width * viewSize.height / imageSize.height)
            } else {
                return CGSize(width: viewSize.width * imageSize.width / imageSize.height, height: viewSize.width)
            }
        } else {
            if imageSize.width > imageSize.height{
                return CGSize(width: viewSize.width, height: imageSize.height * viewSize.width / imageSize.width)
            } else {
                return CGSize(width: imageSize.width * viewSize.height / imageSize.height, height: viewSize.height)
            }
        }
    }
}
