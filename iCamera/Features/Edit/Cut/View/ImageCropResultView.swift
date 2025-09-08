//
//  ImageCropResultView.swift
//  iCamera
//
//  Created by 홍승아 on 2/9/25.
//

import SwiftUI
import PixCrop

struct ImageCropResultView: UIViewRepresentable{
    @ObservedObject var pixCropManager: PixCropManager
    var frame: CGRect
    var image: UIImage?
    var oppacity: CGFloat = 1
    
    func makeUIView(context: Context) -> PixCropResultView{
        var pixCropView = pixCropManager.pixCropView
        
        if let image = image, pixCropManager.isInitialized() == false {
            pixCropView = PixCropView(frame: frame, image: image)
        }
        
        let resultView = pixCropView.pixCropEnded(frame: frame)
        
        if let image = image {
            resultView.image = image
        }
        
        resultView.alpha = oppacity
        
        return resultView
    }
    
    func updateUIView(_ uiView: PixCropResultView, context: Context) {
    }
}
