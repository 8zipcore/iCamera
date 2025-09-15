//
//  ImageCropView.swift
//  iCamera
//
//  Created by 홍승아 on 2/9/25.
//

import SwiftUI
import PixCrop

struct ImageCropView: UIViewRepresentable{
  @Binding var pixCropView: PixCropView
  
  func makeUIView(context: Context) -> PixCropView {
    return pixCropView
  }
  
  func updateUIView(_ uiView: PixCropView, context: Context) {
    Task { @MainActor in pixCropView = uiView }
  }
}
