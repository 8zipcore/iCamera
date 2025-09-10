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
      let viewSize = geometry.size
      
      ZStack {
        if isCutSelected {
          ImageCropView(pixCropManager: pixCropManager)
        } else {
          if let image = image {
            ImageCropResultView(
              pixCropManager: pixCropManager,
              frame: CGRect(origin: .zero, size: viewSize),
              image: image
            )
            
            if filterManager.isSelectedFilter {
              if let filteredImage = filterManager.filterImage(
                image: image,
                targetSize: pixCropManager.pixCropView.image.size
              ) {
                ImageCropResultView(
                  pixCropManager: pixCropManager,
                  frame: CGRect(origin: .zero, size: viewSize),
                  image: filteredImage,
                  oppacity: filterManager.filterValue
                )
              }
            }
          }
        }
      }
      .background(.yellow)
      .onChange(of: image){ _ in
        if let image = image,
           cutImageManager.imageRatio == .zero {
          cutImageManager.imageRatio = cutImageManager.ratio(size: image.size)
          pixCropManager.initPixCropView(size: viewSize, image: image)
        }
      }
    }
  }
}
