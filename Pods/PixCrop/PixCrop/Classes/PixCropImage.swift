//
//  PixCropImage.swift
//  Pods
//
//  Created by 홍승아 on 1/13/25.
//

import Foundation

struct PixCropImage{
    static var center: CGPoint = .zero
    static var lastCenter: CGPoint = .zero
    
    static var zoomScale: CGFloat = 1.0
    static var lastZoomScale: CGFloat = 1.0
    static var transformScale: CGPoint = CGPoint(x: 1, y: 1)
    static var originalSize: CGSize = .zero // 회전이 적용되지 않은 크기
    static var size: CGSize = .zero // 회전이 적용된 크기
    static var degree: Int = .zero
    static var isFlippedHorizontally = false
    static var isFlippedVertically = false
    
    static var maxZoomScale: CGFloat = 10
    
    static func flipHorizontally(){
        transformScale.x *= -1
        transformScale.y = 1
        isFlippedHorizontally.toggle()
    }
    
    static func flipVertically(){
        transformScale.x = 1
        transformScale.y *= -1
        isFlippedVertically.toggle()
    }
    
    static func rotate(_ direction: PixCropRotateDirection){
        switch direction {
        case .left:
            degree = (degree - 90) % 360
        case .right:
            degree = (degree + 90) % 360
        }
    }
    
    static func swapTransform(_ transform: CGPoint){
        transformScale.x = transform.y
        transformScale.y = transform.x
    }
    
    static func degreeToRadian() -> CGFloat{
        return CGFloat(degree) * .pi / 180
    }
    
    static func isHorizontalDegree() -> Bool{
        return (degree / 90) % 2 == 0
    }
    
    static func update(center: CGPoint, zoomScale: CGFloat? = nil, updateLast: Bool = false){
        self.center = center
        
        if updateLast{
            lastCenter = center
        }
        
        if let zoomScale = zoomScale {
            self.zoomScale = max(self.zoomScale * zoomScale, 1)
            
            if updateLast{
                lastZoomScale = zoomScale
            }
        }
    }
    
    static func position(for location: LocationType) -> CGPoint {
        let centerX = PixCropImage.center.x
        let centerY = PixCropImage.center.y
        
        let halfWidth = size.width * zoomScale / 2
        let halfHeight = size.height * zoomScale / 2
        
        var xScale: CGFloat = .zero
        var yScale: CGFloat = .zero
        
        if location.isLeading {
            xScale = -1
        } else if location.isTrailing {
            xScale = 1
        }
        
        if location.isTop{
            yScale = -1
        } else if location.isBottom {
            yScale = 1
        }
        
        return CGPoint(x: centerX + halfWidth * xScale,
                       y: centerY + halfHeight * yScale)
    }
    
    static func reset(){
        center = .zero
        lastCenter = .zero
        zoomScale = 1.0
        lastZoomScale = 1.0
        transformScale = CGPoint(x: 1, y: 1)
        originalSize = .zero
        size = .zero
        degree = .zero
        isFlippedHorizontally = false
        isFlippedVertically = false
    }
}

enum PixCropRotateDirection{
    case left
    case right
}
