//
//  LayoutUtils.swift
//  Pods
//
//  Created by 홍승아 on 1/13/25.
//

import Foundation

enum LayoutUtils {
    
    static func topLeadingPosition(size: CGSize, centerPosition: CGPoint) -> CGPoint {
        return CGPoint(x: centerPosition.x - size.width / 2,
                       y: centerPosition.y - size.height / 2)
    }
    
    static func scaledSizeToFit(size: CGSize, viewSize: CGSize) -> CGSize{
        let widthRatio = viewSize.width / size.width
        let heightRatio = viewSize.height / size.height
        
        let scale = min(widthRatio, heightRatio)
        
        return CGSize(width: size.width * scale,
                      height: size.height * scale)
    }
    
    static func scale(size: CGSize, viewSize: CGSize) -> CGFloat{
        let widthRatio = viewSize.width / size.width
        let heightRatio = viewSize.height / size.height
        
        return min(widthRatio, heightRatio)
    }
    
    static func maxScale(size: CGSize, viewSize: CGSize) -> CGFloat{
        let widthRatio = viewSize.width / size.width
        let heightRatio = viewSize.height / size.height
        
        return max(widthRatio, heightRatio)
    }
    
    static func center(for size: CGSize) -> CGPoint{
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    static func center(_ position: CGPoint, _ size: CGSize) -> CGPoint{
        return CGPoint(x: position.x + (size.width / 2), y: position.y + (size.height / 2))
    }
    
    static func position(_ locationType: LocationType, _ size: CGSize, _ center: CGPoint) -> CGPoint{
        
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        
        var xScale: CGFloat = .zero
        var yScale: CGFloat = .zero
        
        if locationType.isLeading{
            xScale = -1
        } else if locationType.isTrailing{
            xScale = 1
        }
        
        if locationType.isTop{
            yScale = -1
        } else if locationType.isBottom{
            yScale = 1
        }
        
        return CGPoint(x: center.x + halfWidth * xScale , y: center.y + halfHeight * yScale)
    }
}
