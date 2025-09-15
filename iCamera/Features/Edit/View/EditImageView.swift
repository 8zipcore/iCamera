//
//  EditImageView.swift
//  iCamera
//
//  Created by 홍승아 on 9/30/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct EditImageView: View {
  @Binding var image: UIImage?
  var isCutSelected: Bool
  @ObservedObject var filterManager: FilterManager
  @ObservedObject var cutImageManager: CutImageManager
  @ObservedObject var pixCropManager: PixCropManager
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if isCutSelected {
          ImageCropView(pixCropView: $pixCropManager.pixCropView)
        } else {
          if geometry.size.height > 0,
             let image = image {
            ImageCropResultView(
              pixCropManager: pixCropManager,
              frame: CGRect(origin: .zero, size: geometry.size),
              image: image
            )
            .onAppear {
              initImage(containerSize: geometry.size)
            }
            
            if filterManager.isSelectedFilter {
              if let filteredImage = filterManager.filterImage(
                image: image,
                targetSize: pixCropManager.pixCropView.image.size
              ) {
                ImageCropResultView(
                  pixCropManager: pixCropManager,
                  frame: CGRect(origin: .zero, size: geometry.size),
                  image: filteredImage,
                  oppacity: filterManager.filterValue
                )
              }
            }
          }
        }
      }
    }
  }
  
  private func initImage(containerSize: CGSize) {
    if let image = image,
       cutImageManager.imageRatio == .zero {
      cutImageManager.imageRatio = cutImageManager.ratio(size: image.size)
      pixCropManager.initPixCropView(size: containerSize, image: image)
    }
  }
}
