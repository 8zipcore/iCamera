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


class CutImageManager: ObservableObject{
    var selectionFrameDrag = PassthroughSubject<SelectionFrameRectangleData, Never>()
    var selectionFrameDragEnded = PassthroughSubject<SelectionFrameRectangleData, Never>()
    var imageZoom = PassthroughSubject<CGFloat, Never>()
    var imageZoomEnded = PassthroughSubject<Void, Never>()
    var imageDrag = PassthroughSubject<CGPoint, Never>()
    var imageDragEnded = PassthroughSubject<CGPoint, Never>()
}
