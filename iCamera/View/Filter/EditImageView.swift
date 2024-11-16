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
    
    @Binding var inputImage: UIImage?
    var value: CGFloat = 0
    var filterType: FilterType
    
    @StateObject var menuButtonManager: MenuButtonManager
    @StateObject var cutImageManager: CutImageManager
    
    @State private var image: UIImage = UIImage()
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            VStack{
                if let filteredImage = applyFilters(to: image) {
                    if menuButtonManager.isSelected(.cut){
                        CutImageView(image: filteredImage,
                                     frameWidth: cutImageManager.frameWidth,
                                     frameHeight: cutImageManager.frameHeight,
                                     cutImageManager: cutImageManager)
                        .frame(width: viewWidth , height: viewHeight)
                    } else {
                        let imageSize = cutImageManager.imageSize(imageSize: image.size, viewSize: geometry.size)
                        
                        ZStack{
                            var imagePosition = cutImageManager.imagePosition
                            if cutImageManager.frameWidth > cutImageManager.frameHeight{
                                //imagePosition.x -= 15
                            } else {
                                // imagePosition.y -= 15
                            }
                            Image(uiImage: filteredImage)
                                .resizable()
                                .scaledToFill()
                                .scaleEffect(cutImageManager.zoomScale)
                                .scaleEffect(x: cutImageManager.currentFlipHorizontal.x, y: cutImageManager.currentFlipHorizontal.y)
                                .rotationEffect(.degrees(cutImageManager.currentDegree))
                                .frame(width: imageSize.width, height: imageSize.height)
                                .position(x: cutImageManager.imagePosition.x, y: imagePosition.y)
                            
                            // ⚠️ imagePosition 약간 어긋나는 오류 해결할 것 !!
                            let maskRectangleSize = cutImageManager.paddingImageSize(imageSize: CGSize(width: cutImageManager.frameWidth, height: cutImageManager.frameHeight), multiple: 1)
                            let maskRectangleViewLocation = CGPoint(x: (viewWidth - maskRectangleSize.width) / 2, y: (viewHeight - maskRectangleSize.height) / 2)
                            MaskRectangleView(overlayColor: .white,
                                              rectangleSize: geometry.size,
                                              maskRectangleSize: maskRectangleSize,
                                              maskPosition: CGPoint(x: maskRectangleViewLocation.x, y: maskRectangleViewLocation.y))
                        }
                    }
                }
            }
            .clipped()
            .onChange(of: inputImage) { _ in
                if let inputImage = inputImage{
                    image = inputImage
                    let imageSize = cutImageManager.imageSize(imageSize: image.size, viewSize: geometry.size)
                    let paddingImageSize = cutImageManager.paddingImageSize(imageSize: imageSize, multiple: -1)
                    cutImageManager.initFrameSize(paddingImageSize)
                    cutImageManager.imagePosition = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
                    cutImageManager.editImageViewSize = geometry.size
                }
            }
        }
    }
    
    private func applyFilters(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let context = CIContext()
        var finalImage: CIImage?
        
        switch filterType {
        case .none:
            finalImage = ciImage
        case .bloom:
            let bloomFilter = CIFilter.bloom()
            bloomFilter.inputImage = ciImage
            bloomFilter.intensity = Float(value)
            finalImage = bloomFilter.outputImage
        }
        
        guard let finalImage = finalImage else { return nil}
        
        // CIContext를 통해 최종 이미지 생성
        if let cgImage = context.createCGImage(finalImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
