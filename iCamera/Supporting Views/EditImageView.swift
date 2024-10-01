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
    
    var body: some View {
        if let filteredImage = applyFilters(to: inputImage) {
            Image(uiImage: filteredImage)
                .resizable()
                .scaledToFit()
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
