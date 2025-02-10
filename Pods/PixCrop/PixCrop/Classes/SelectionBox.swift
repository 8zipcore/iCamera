//
//  SelectionBox.swift
//  PixCrop
//
//  Created by 홍승아 on 1/9/25.
//

import Foundation
struct SelectionBox{
    let lineWidth: CGFloat = 4
    let boxSize = CGSize(width: 20, height: 20)
    var locationType: LocationType = .none
    
    func maskRect() -> CGRect{
        var maskPosition: CGPoint = .zero
        let padding: CGFloat = 10
        var maskBoxWidth: CGFloat = boxSize.width - lineWidth + padding
        var maskBoxHeight = maskBoxWidth
        
        switch locationType {
        case .topLeading:
            maskPosition.x = lineWidth
            maskPosition.y = lineWidth
        case .top:
            maskPosition.x = -padding / 2
            maskPosition.y = lineWidth
            maskBoxWidth = boxSize.width + padding
        case .topTrailing:
            maskPosition.x = -padding
            maskPosition.y = lineWidth
        case .centerLeading:
            maskPosition.x = lineWidth
            maskPosition.y = -padding / 2
            maskBoxHeight = boxSize.height + padding
        case .centerTrailing:
            maskPosition.x = -padding
            maskPosition.y = -padding / 2
            maskBoxHeight = boxSize.height + padding
        case .bottomLeading:
            maskPosition.x = lineWidth
            maskPosition.y = -padding
        case .bottom:
            maskPosition.x = -padding / 2
            maskPosition.y = -padding
            maskBoxWidth = boxSize.width + padding
        case .bottomTrailing:
            maskPosition.x = -padding
            maskPosition.y = -padding
        case .none:
            break
        }
        
        return CGRect(x: maskPosition.x, y: maskPosition.y, width: maskBoxWidth, height: maskBoxHeight)
    }
}

enum LocationType: Int, CaseIterable{
    case none
    case topLeading, top, topTrailing
    case centerLeading, centerTrailing
    case bottomLeading, bottom, bottomTrailing
    
    var isLeading: Bool{
        return [.topLeading, .centerLeading, .bottomLeading].contains(self)
    }
    
    var isTrailing: Bool{
        return [.topTrailing, .centerTrailing, .bottomTrailing].contains(self)
    }
    
    var isTop: Bool{
        return [.topLeading, .top, .topTrailing].contains(self)
    }
    
    var isBottom: Bool{
        return [.bottomLeading, .bottom, .bottomTrailing].contains(self)
    }
    
    var isCenter: Bool{
        return self == .centerLeading || self == .centerTrailing
    }
}
