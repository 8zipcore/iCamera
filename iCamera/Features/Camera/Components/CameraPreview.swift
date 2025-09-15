//
//  CameraPreview.swift
//  iCamera
//
//  Created by 홍승아 on 9/15/25.
//

import SwiftUI

struct CameraPreview: UIViewRepresentable {
  @ObservedObject var cameraManager: CameraManager
  var frame: CGRect
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: frame)
    if let previewLayer = cameraManager.previewLayer {
      previewLayer.frame = view.bounds
      view.layer.addSublayer(previewLayer)
    }
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    uiView.frame = frame
  }
}
