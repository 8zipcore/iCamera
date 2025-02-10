//
//  PixCropFrame.swift
//  Pods
//
//  Created by 홍승아 on 1/24/25.
//

import Foundation

struct PixCropFrame{
    static var width: CGFloat = .zero
    static var height: CGFloat = .zero
    static var size: CGSize{
        return CGSize(width: width, height: height)
    }
    static var lastSize: CGSize = .zero
    static var center: CGPoint = .zero
    static var lastCenter: CGPoint = .zero
    
    static let lineWidth: CGFloat = 2
    static var contentSize: CGSize{
        return CGSize(width: width + inset.left + inset.right + lineWidth * 2,
                      height: height + inset.top + inset.bottom + lineWidth * 2)
    }
    static var inset: UIEdgeInsets{
        let padding = SelectionBox().lineWidth
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    static var minWidth: CGFloat = .zero
    static var minHeight: CGFloat = .zero
    
    static func update(size: CGSize, center: CGPoint? = nil, updateLast: Bool = false ){
        self.width = size.width
        self.height = size.height
        
        if let center = center{
            self.center = center
            if updateLast {
                lastCenter = center
            }
        }
        
        if updateLast{
            lastSize = size
        }
    }
    
    static func position(for location: LocationType, _ frameSize: CGSize, _ center: CGPoint) -> CGPoint {
        let halfWidth = frameSize.width / 2
        let halfHeight = frameSize.height / 2
        
        var framePosition: CGPoint = .zero
        
        if location.isLeading{
            framePosition.x = center.x - halfWidth
        } else if location.isTrailing {
            framePosition.x = center.x + halfWidth
        }
        
        if location.isTop{
            framePosition.y = center.y - halfHeight
        } else if location.isBottom {
            framePosition.y = center.y + halfHeight
        }
        
        return framePosition
    }
    
    static func position(for location: LocationType) -> CGPoint{
        return position(for: location, size, center)
    }
    
    static func reset(){
        width = .zero
        height = .zero
        
        lastSize = .zero
        center = .zero
        lastCenter = .zero
        
        minWidth = .zero
        minHeight = .zero
    }
}
