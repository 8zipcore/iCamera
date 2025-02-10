//
//  PixCropFrameManager.swift
//  PixCrop
//
//  Created by 홍승아 on 1/9/25.
//

import Foundation

class PixCropFrameManager{
    
    func dragFrame(selectionBox: SelectionBox, location: CGPoint, viewSizeWithoutPadding: CGSize, viewCenter: CGPoint){
        if PixCropImage.zoomScale > PixCropImage.maxZoomScale{
            return
        }
        
        let frameSize = PixCropFrame.size
        
        var newFrameSize = PixCropFrame.size
        var newFrameCenter = PixCropFrame.center

        var widthDifferenceValue: CGFloat = .zero
        var heightDifferenceValue: CGFloat = .zero
        
        let locationType = selectionBox.locationType
        
        if locationType.isLeading{
            widthDifferenceValue = location.x
            newFrameCenter.x += (widthDifferenceValue / 2)
        } else if locationType.isTrailing{
            widthDifferenceValue = frameSize.width - location.x
            newFrameCenter.x -= (widthDifferenceValue / 2)
        }
        
        if locationType.isTop{
            heightDifferenceValue = location.y
            newFrameCenter.y += (heightDifferenceValue / 2)
        } else if locationType.isBottom{
            heightDifferenceValue = frameSize.height - location.y
            newFrameCenter.y -= (heightDifferenceValue / 2)
        }
        
        let minSize = CGSize(width: PixCropFrame.minWidth, height: PixCropFrame.minHeight)
        
        newFrameSize.width -= widthDifferenceValue
        newFrameSize.height -= heightDifferenceValue
        
        let resizeFrame = resizeFrameToFitImage(locationType: selectionBox.locationType,
                                                 newRect: CGRect(origin: newFrameCenter, size: newFrameSize),
                                                 viewSize: viewSizeWithoutPadding,
                                                 viewCenter: viewCenter)
        
        let isWidthBelowMin = resizeFrame.width < minSize.width
        let isHeightBelowMin = resizeFrame.height < minSize.height
        
        newFrameSize.width = isWidthBelowMin ? PixCropFrame.size.width : resizeFrame.size.width
        newFrameSize.height = isHeightBelowMin ? PixCropFrame.size.height : resizeFrame.size.height
        newFrameCenter.x = isWidthBelowMin ? PixCropFrame.center.x : resizeFrame.origin.x
        newFrameCenter.y = isHeightBelowMin ? PixCropFrame.center.y : resizeFrame.origin.y
        
        PixCropFrame.update(size: newFrameSize, center: newFrameCenter)
    }
    
    func dragFrameEnded(selectionBox: SelectionBox, viewSizeWithoutPadding: CGSize, viewCenter: CGPoint){
        let newFrameSize = LayoutUtils.scaledSizeToFit(size: PixCropFrame.size, viewSize: viewSizeWithoutPadding)
        let imageScale = LayoutUtils.scale(size: PixCropFrame.size, viewSize: viewSizeWithoutPadding)
        
        var fixedLocation: LocationType = .none
        
        switch selectionBox.locationType{
        case .topLeading:
            fixedLocation = .bottomTrailing
        case .top: fallthrough
        case .topTrailing:
            fixedLocation = .bottomLeading
        case .centerLeading: fallthrough
        case .bottomLeading:
            fixedLocation = .topTrailing
        case .centerTrailing: fallthrough
        case .bottom: fallthrough
        case .bottomTrailing:
            fixedLocation = .topLeading
        default: break
        }
        
        let locationPosition = PixCropFrame.position(
            for: fixedLocation,
            PixCropFrame.size,
            PixCropFrame.center
        )
        
        let newLocationPosition = PixCropFrame.position(
            for: fixedLocation,
            newFrameSize,
            viewCenter
        )
        
        let newImagePosition = CGPoint(
            x: PixCropImage.center.x * imageScale + (newLocationPosition.x - locationPosition.x * imageScale),
            y: PixCropImage.center.y * imageScale + (newLocationPosition.y - locationPosition.y * imageScale)
        )
        
        PixCropImage.update(
            center: newImagePosition,
            zoomScale: imageScale,
            updateLast: true
        )
        
        PixCropFrame.update(size: newFrameSize,
                     center: viewCenter,
                     updateLast: true)
        
    }
    
    func ratio(ratio: CGSize, viewSize: CGSize){
        let lastFrameSize = PixCropFrame.size
        var ratioFrameSize: CGSize = .zero
        ratioFrameSize.width = lastFrameSize.width * (ratio.width / ratio.height)
        ratioFrameSize.height = ratioFrameSize.width * (ratio.height / ratio.width)
        var newFrameSize = LayoutUtils.scaledSizeToFit(
            size: ratioFrameSize,
            viewSize: viewSize
        )
        newFrameSize.width = max(PixCropFrame.minWidth, newFrameSize.width)
        newFrameSize.height = max(PixCropFrame.minHeight, newFrameSize.height)
        
        PixCropFrame.update(size: newFrameSize)
    }
    
    private func resizeFrameToFitImage(locationType: LocationType, newRect: CGRect, viewSize: CGSize, viewCenter: CGPoint) -> CGRect{
        var adjustedFrameSize = newRect.size
        var adjustedFrameCenter = newRect.origin
        let imagePosition = PixCropImage.position(for: locationType)
        let framePosition = PixCropFrame.position(for: locationType, adjustedFrameSize, adjustedFrameCenter)
        let viewPosition = LayoutUtils.position(locationType, viewSize, viewCenter)
        
        if locationType.isLeading {
            if framePosition.x < imagePosition.x || framePosition.x < viewPosition.x{
                let lastFrameCenterTrailingX = PixCropFrame.position(for: .centerTrailing, PixCropFrame.lastSize, PixCropFrame.lastCenter).x
                let maxX = max(viewPosition.x, imagePosition.x)
                adjustedFrameSize.width = lastFrameCenterTrailingX - maxX
                adjustedFrameCenter.x = maxX + adjustedFrameSize.width / 2
            }
        } else if locationType.isTrailing {
            if framePosition.x > imagePosition.x || framePosition.x > viewPosition.x{
                let lastFrameCenterLeadingX = PixCropFrame.position(for: .centerLeading, PixCropFrame.lastSize, PixCropFrame.lastCenter).x
                let minX = min(viewPosition.x, imagePosition.x)
                adjustedFrameSize.width = minX - lastFrameCenterLeadingX
                adjustedFrameCenter.x = minX - adjustedFrameSize.width / 2
            }
        }
        
        if locationType.isTop {
            if framePosition.y < imagePosition.y || framePosition.y < viewPosition.y{
                let lastFrameBottomY = PixCropFrame.position(for: .bottom, PixCropFrame.lastSize, PixCropFrame.lastCenter).y
                let maxY = max(viewPosition.y, imagePosition.y)
                adjustedFrameSize.height = lastFrameBottomY - maxY
                adjustedFrameCenter.y = maxY + adjustedFrameSize.height / 2
            }
        } else if locationType.isBottom {
            if framePosition.y > imagePosition.y || framePosition.y > viewPosition.y{
                let lastFrameTopY = PixCropFrame.position(for: .top, PixCropFrame.lastSize, PixCropFrame.lastCenter).y
                let minY = min(viewPosition.y, imagePosition.y)
                adjustedFrameSize.height = minY - lastFrameTopY
                adjustedFrameCenter.y = minY - adjustedFrameSize.height / 2
            }
        }
        
        return CGRect(origin: adjustedFrameCenter, size: adjustedFrameSize)
    }
}
