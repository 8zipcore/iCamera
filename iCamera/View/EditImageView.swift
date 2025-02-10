//
//  EditImageView.swift
//  iCamera
//
//  Created by 홍승아 on 9/30/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

@available(iOS 16.0, *)
struct EditImageView: View {
    @Binding var image: UIImage?
    @StateObject var filterManager: FilterManager
    @StateObject var menuButtonManager: MenuButtonManager
    @StateObject var cutImageManager: CutImageManager
    @StateObject var pixCropManager: PixCropManager
    
    var body: some View {
        GeometryReader { geometry in
            let viewSize = geometry.size
            
            VStack{
                if let image = image {
                    if menuButtonManager.isSelected(.cut){
                        ImageCropView(pixCropManager: pixCropManager)
                    } else {
                        ZStack{
                            ImageCropResultView(
                                pixCropManager: pixCropManager,
                                frame: CGRect(origin: .zero, size: viewSize),
                                image: image
                            )
                            
                            if filterManager.selectedFilter.type != .none{
                                if let filteredImage = filterManager.filterImage(image: image){
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
            }
            .clipped()
            .onChange(of: image){ _ in
                if let image = image, cutImageManager.imageRatio == .zero{
                    cutImageManager.imageRatio = cutImageManager.ratio(size: image.size)
                    pixCropManager.initPixCropView(size: viewSize, image: image)
                }
            }
        }
    }
}
