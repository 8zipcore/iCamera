//
//  ImageCropView.swift
//  iCamera
//
//  Created by 홍승아 on 2/9/25.
//

import SwiftUI
import PixCrop

struct ImageCropView: UIViewRepresentable{
    @ObservedObject var pixCropManager: PixCropManager

    func makeUIView(context: Context) -> PixCropView{
        return pixCropManager.pixCropView
    }
    
    func updateUIView(_ uiView: PixCropView, context: Context) {
        DispatchQueue.main.async{
            pixCropManager.pixCropView = uiView
        }
    }
}
