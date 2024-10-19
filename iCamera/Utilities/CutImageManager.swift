//
//  CutImageManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/6/24.
//

import SwiftUI
import Combine

struct SelectionFrameRectangleData{
    var selectionFrameRectangle: SelectionFrameRectangle
    var position: CGPoint
}

struct SelectionFrameRectangle: Hashable{
    enum Location: CaseIterable{
        case lt, t, tt
        case lc, tc
        case lb, b, tb
    }
    
    enum LocationType{
        case vertex, edge
    }
    
    var location: Location
    var type: LocationType{
        switch location {
        case .lt: fallthrough
        case .tt: fallthrough
        case .lb: fallthrough
        case .tb:
            return .vertex
        case .t: fallthrough
        case .lc: fallthrough
        case .tc: fallthrough
        case .b:
            return .edge
        }
    }
    
    var scale: CGPoint{
        switch location {
        case .lt:
            return CGPoint(x: -1, y: -1)
        case .t:
            return CGPoint(x: 0, y: -1)
        case .tt:
            return CGPoint(x: 1, y: -1)
        case .lc:
            return CGPoint(x: -1, y: 0)
        case .tc:
            return CGPoint(x: 1, y: 0)
        case .lb:
            return CGPoint(x: -1, y: 1)
        case .b:
            return CGPoint(x: 0, y: 1)
        case .tb:
            return CGPoint(x: 1, y: 1)
        }
    }
    
    func maskRectangleSize(lineSize: CGSize) -> CGSize{
        let lineWidth = lineSize.width
        let lineHeight = lineSize.height
        switch type{
        case .vertex:
            return CGSize(width: lineHeight - lineWidth, height: lineHeight - lineWidth)
        case.edge:
            if location == .t || location == .b{
                return CGSize(width: lineHeight, height: lineHeight - lineWidth)
            } else {
                return CGSize(width: lineHeight - lineWidth, height: lineHeight)
            }
        }
    }
    
    func maskPosition(lineSize: CGSize) -> CGPoint{
        let lineWidth = lineSize.width
        switch location {
        case .lt:
            return CGPoint(x: lineWidth, y: lineWidth)
        case .t:
            return CGPoint(x: 0, y: lineWidth)
        case .tt:
            return CGPoint(x: 0, y: lineWidth)
        case .lc:
            return CGPoint(x: lineWidth, y: 0)
        case .tc:
            return CGPoint(x: 0, y: 0)
        case .lb:
            return CGPoint(x: lineWidth, y: 0)
        case .b:
            return CGPoint(x: 0, y: 0)
        case .tb:
            return CGPoint(x: 0, y: 0)
        }
    }
}

struct FrameRatio: Hashable{
    var widthRatio: CGFloat
    var heightRatio: CGFloat
    var string: String{
        return "\(widthRatio) : \(heightRatio)"
    }
}


class CutImageManager: ObservableObject{
    var selectionFrameDrag = PassthroughSubject<SelectionFrameRectangleData, Never>()
    var selectionFrameDragEnded = PassthroughSubject<SelectionFrameRectangleData, Never>()
    var imageZoom = PassthroughSubject<CGFloat, Never>()
    var imageZoomEnded = PassthroughSubject<Void, Never>()
    var imageDrag = PassthroughSubject<CGPoint, Never>()
    var imageDragEnded = PassthroughSubject<CGPoint, Never>()
    var frameRatioTapped = PassthroughSubject<FrameRatio, Never>()
    
    @Published var imageRatio: CGSize = .zero
    var ratioArray: [FrameRatio] {
        var ratioArray: [FrameRatio] = []
        ratioArray =  [
            FrameRatio(widthRatio: imageRatio.width, heightRatio: imageRatio.height),
            frameRatio(aspectRatio: CGSize(width: 1, height: 1)),
            frameRatio(aspectRatio: CGSize(width: 9, height: 16)),
            frameRatio(aspectRatio: CGSize(width: 4, height: 5)),
            frameRatio(aspectRatio: CGSize(width: 5, height: 7)),
            frameRatio(aspectRatio: CGSize(width: 3, height: 4)),
            frameRatio(aspectRatio: CGSize(width: 3, height: 5)),
            frameRatio(aspectRatio: CGSize(width: 2, height: 3)),
        ]
        return ratioArray
    }
    
    func frameRatio(aspectRatio: CGSize) -> FrameRatio{
        if imageRatio.width > imageRatio.height{
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
            resultPosition.y += imagePositionArray[1].y - framePositionArray[1].y
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
            resultPosition.y += imagePositionArray[6].y - framePositionArray[6].y
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
    
    func updateFrameData(location: SelectionFrameRectangle.Location, previousFramePositionArray: [CGPoint], framePositionArray: [CGPoint], imagePositionArray: [CGPoint], viewWidth: CGFloat, viewHeight: CGFloat, viewCenter: CGPoint, newSize: CGSize, newLocation: CGPoint, framePosition: CGPoint, frameWidth: CGFloat, frameHeight: CGFloat) -> (CGSize, CGPoint){
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
}
