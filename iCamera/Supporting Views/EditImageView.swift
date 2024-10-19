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
    
    var inputImage: UIImage
    var value: CGFloat = 0
    var filterType: FilterType
    
    @StateObject var menuButtonManager: MenuButtonManager
    @StateObject var cutImageManger: CutImageManager
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            if let filteredImage = applyFilters(to: inputImage) {
                let imageSize = imageSize(geometry.size)
                if menuButtonManager.isSelected(.cut){
                    let padding: CGFloat = 15
                    let paddingImageSize = CGSize(width: imageSize.width - padding, height: imageSize.height - padding)
                    
                    CutImageView(image: filteredImage,
                                 frameWidth: paddingImageSize.width,
                                 frameHeight: paddingImageSize.height,
                                 cutImageManager: cutImageManger,
                                 padding: padding)
                    .frame(width: viewWidth , height: viewHeight)
                } else {
                    Image(uiImage: filteredImage)
                        .resizable()
                        .scaledToFit()
                        .position(x: viewWidth / 2, y: viewHeight / 2)
                }
            }
        }
    }
    
    func imageSize(_ viewSize: CGSize) -> CGSize{
        let inputImageSize = inputImage.size
        
        if inputImageSize.width > inputImageSize.height{
            return CGSize(width: viewSize.width, height: inputImageSize.height * viewSize.width / inputImageSize.width)
        } else {
            return CGSize(width: inputImageSize.width * viewSize.height / inputImageSize.height, height: viewSize.height)
        }
    }
    
    func applyFilters(to image: UIImage) -> UIImage? {
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
