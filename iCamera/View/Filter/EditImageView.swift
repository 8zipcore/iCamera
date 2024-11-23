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
                        let imageSize = imageSize(imageSize: cutImageManager.imageSize, viewSize: geometry.size)
                        ZStack{
                            let frameSize = cutImageManager.paddingImageSize(imageSize: CGSize(width: cutImageManager.frameWidth, height: cutImageManager.frameHeight), multiple: 1)
                            let maskRectangleSize = updateImageSizeWithoutLineSize(imageSize: frameSize, viewSize: geometry.size)
                            let maskRectangleViewLocation = CGPoint(x: (viewWidth - maskRectangleSize.width) / 2, y: (viewHeight - maskRectangleSize.height) / 2)
                            let imagePosition = imagePosition(imageSize: imageSize, maskRectangleSize: maskRectangleSize, viewSize: geometry.size)
  
                            Image(uiImage: filteredImage)
                                .resizable()
                                .scaledToFill()
                                .scaleEffect(cutImageManager.zoomScale)
                                .scaleEffect(x: cutImageManager.currentFlipHorizontal.x, y: cutImageManager.currentFlipHorizontal.y)
                                .rotationEffect(.degrees(cutImageManager.currentDegree))
                                .frame(width: imageSize.width, height: imageSize.height)
                                .position(x: imagePosition.x, y: imagePosition.y)

                            
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
    
    private func imagePosition(imageSize: CGSize, maskRectangleSize: CGSize, viewSize: CGSize) -> CGPoint{
        let imagePosition = cutImageManager.imagePosition
        let frameLocation = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        let previousImageSize = cutImageManager.imageSize
        let newFrameXPoint: CGFloat = imagePosition.x + (frameLocation.x - imagePosition.x) * (imageSize.width / previousImageSize.width)
        let newFrameYPoint: CGFloat = imagePosition.y +  (frameLocation.y - imagePosition.y) * (imageSize.height / previousImageSize.height)
        
        let resultXPoint: CGFloat = imagePosition.x + frameLocation.x - newFrameXPoint
        let resultYPoint: CGFloat = imagePosition.y + frameLocation.y - newFrameYPoint
        
        return CGPoint(x: resultXPoint, y: resultYPoint)
    }
    
    private func updateImageSizeWithoutLineSize(imageSize: CGSize, viewSize: CGSize) -> CGSize{
        let difference = cutImageManager.frameRectangleLineWidth * 2
        if imageSize.width == viewSize.width{
            return CGSize(width: imageSize.width, height: imageSize.height - difference)
        } else if imageSize.height == viewSize.height{
            return CGSize(width: imageSize.width - difference, height: imageSize.height)
        } else {
            return CGSize(width: imageSize.width - difference, height: imageSize.height - difference)
        }
    }
    
    private func imageSize(imageSize: CGSize, viewSize: CGSize) -> CGSize{
        if cutImageManager.isHorizontalDegree(){
            if imageSize.width > imageSize.height{
                return CGSize(width: viewSize.height, height: imageSize.width * viewSize.height / imageSize.height)
            } else {
                print(CGSize(width: viewSize.width * imageSize.width / imageSize.height, height: viewSize.width))
                return CGSize(width: viewSize.width * imageSize.width / imageSize.height, height: viewSize.width)
            }
        } else {
            if imageSize.width > imageSize.height{
                return CGSize(width: viewSize.width, height: imageSize.height * viewSize.width / imageSize.width)
            } else {
                return CGSize(width: imageSize.width * viewSize.height / imageSize.height, height: viewSize.height)
            }
        }
    }
}
