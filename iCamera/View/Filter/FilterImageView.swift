//
//  FilterImageView.swift
//  iCamera
//
//  Created by 홍승아 on 9/23/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilteredImageView: View {
    let context = CIContext()
    let colorControlsFilter = CIFilter.colorControls() // 밝기, 대비 필터
    let highlightShadowFilter = CIFilter.highlightShadowAdjust() // 하이라이트, 섀도우 필터
    
    var inputImage: UIImage
    
    var filterValue: CGFloat = 0.0
    
    
    var body: some View {
        if let reducedImage = reduceImageSize(image: inputImage, scale: 0.2) {
            if let filteredImage = applyFilters(to: reducedImage) {
                Image(uiImage: filteredImage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
        
    func reduceImageSize(image: UIImage, scale: CGFloat) -> UIImage? {
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return newImage
    }

    func applyFilters(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let bloomFilter = CIFilter.bloom()
        bloomFilter.inputImage = ciImage
        bloomFilter.intensity = Float(filterValue)
         // 최종 이미지 얻기
         guard let outputImage = bloomFilter.outputImage else { return nil }
        
        // CIContext를 통해 최종 이미지 생성
        if let cgImage = context.createCGImage(outputImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
