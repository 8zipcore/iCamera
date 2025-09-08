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
    
    var ratioArray: [FrameRatio] = []
    
    func ratioDriectionToggle(){
        currentRatioDirection = currentRatioDirection == .horizontal ? .vertical : .horizontal
        
        ratioArray = ratioArray.map { return FrameRatio(widthRatio: $0.heightRatio, heightRatio: $0.widthRatio)}
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
    
    func ratio(size: CGSize) -> CGSize {
        let divisor = CGFloat(gcd(Int(size.width), Int(size.height)))
        return CGSize(width: size.width / divisor, height: size.height / divisor)
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
}
