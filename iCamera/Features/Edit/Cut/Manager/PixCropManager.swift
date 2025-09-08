//
//  PixCropManager.swift
//  iCamera
//
//  Created by 홍승아 on 2/9/25.
//

import Foundation
import PixCrop

class PixCropManager: ObservableObject, Equatable {
    @Published var pixCropView: PixCropView = PixCropView()

    var maskSize: CGSize{
        return pixCropView.maskSize
    }

    static func ==(lhs: PixCropManager, rhs: PixCropManager) -> Bool {
        return lhs.pixCropView == rhs.pixCropView
    }

    func isInitialized() -> Bool {
        return pixCropView.frame.size != .zero
    }

    func reset() {
        pixCropView = PixCropView()
    }
    
    func initPixCropView(size: CGSize, image: UIImage){
        pixCropView = PixCropView(frame: CGRect(origin: .zero, size: size), image: image)
    }

    func scaledSizeToFit(size: CGSize, viewSize: CGSize) -> CGSize {
        let widthRatio = viewSize.width / size.width
        let heightRatio = viewSize.height / size.height
        let scale = min(widthRatio, heightRatio)

        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    func ratio(_ ratio: CGSize) {
        objectWillChange.send()
        pixCropView.ratio(ratio: ratio)
    }

    func flipHorizontally() {
        objectWillChange.send()
        pixCropView.flipHorizontally()
    }

    func rotateLeft() {
        objectWillChange.send()
        pixCropView.rotateLeft()
    }
}
