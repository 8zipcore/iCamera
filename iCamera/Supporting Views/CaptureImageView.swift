//
//  CaptureImageView.swift
//  iCamera
//
//  Created by 홍승아 on 11/24/24.
//

import SwiftUI

struct CaptureImageView: View {
    var image: UIImage
    
    var cutImageManager: CutImageManager
    var textManager: TextManager
    var stickerManager: StickerManager
    var filterManager: FilterManager
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                let imageSize = imageSize(imageSize: cutImageManager.imageSize, viewSize: geometry.size)
                let newZoomScale = calculateNewZoomScale(newSize: imageSize, viewSize: geometry.size)
                let imagePosition = imagePosition(imageSize: imageSize, viewSize: geometry.size, newZoomScale: newZoomScale)
                let zoomDifference = newZoomScale / cutImageManager.zoomScale
                let previousFrameSize = cutImageManager.paddingImageSize(imageSize: CGSize(width: cutImageManager.frameWidth, height: cutImageManager.frameHeight), multiple: 1)
                let newFrameSize = cutImageManager.imageSize(imageSize: CGSize(width: cutImageManager.frameWidth, height: cutImageManager.frameHeight), viewSize: geometry.size)
                
                Rectangle()
                    .stroke(.white, lineWidth: 1.0)
                    .frame(width: imageSize.width, height: imageSize.height)
                
                if let filteredImage = filterManager.applyFilters(to: image) {
                    Image(uiImage: filteredImage)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(newZoomScale)
                        .scaleEffect(x: cutImageManager.currentFlipHorizontal.x, y: cutImageManager.currentFlipHorizontal.y)
                        .rotationEffect(.degrees(cutImageManager.currentDegree))
                        .frame(width: imageSize.width, height: imageSize.height)
                        .position(x: imagePosition.x, y: imagePosition.y)
                }
                
                /* ⭐️ StickerView 시작 */
                ForEach(stickerManager.stickerArray.indices, id:\.self){ index in
                    let sticker = stickerManager.stickerArray[index]
                    let newStickerSize = updateStickerSize(initialSize: sticker.size, frameSize: previousFrameSize, newFrameSize: newFrameSize, newZoomScale: newZoomScale)
                    let newStickerLocation = updatePosition(initialLocation: sticker.location, initialSize: previousFrameSize, newSize: newFrameSize, viewSize: geometry.size, zoomDifference: zoomDifference)
                    
                    let newSticker = stickerManager.updateSticker(sticker: sticker, size: newStickerSize, location: newStickerLocation)
                    
                    StickerView(index: index, sticker: newSticker, stickerManager: stickerManager, editManager: EditManager(), editImageViewPositionArray: [])
                        .frame(width: newStickerSize.width, height: newStickerSize.height)
                        .position(newStickerLocation)
                }
                /* ⭐️ StickerView 끝 (ForEach) */
                /* ⭐️ TextView 시작 */
                ForEach(textManager.textArray.indices, id: \.self){ index in
                    let text = textManager.setTextPlaceHolder(index: index)
                    let newTextSize = updateStickerSize(initialSize: text.size, frameSize: previousFrameSize, newFrameSize: newFrameSize, newZoomScale: newZoomScale)
                    let newTextLocation = updatePosition(initialLocation: text.location, initialSize: previousFrameSize, newSize: newFrameSize, viewSize: geometry.size, zoomDifference: zoomDifference)
                    let newText = textManager.updateText(text: text, size: newTextSize, location: newTextLocation)
                    TextView(index: index, textData: newText, textViewSize: newText.size, textManager: textManager, editManager: EditManager(), editImageViewPositionArray: [], backgroundViewSizeArray: newText.backgroundColorSizeArray)
//                        .frame(width: text.size.width, height: text.size.height)
                        .position(newTextLocation)
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    private func imagePosition(imageSize: CGSize, viewSize: CGSize, newZoomScale: CGFloat) -> CGPoint{
        let frameLocation = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        let xDifference = frameLocation.x - cutImageManager.centerLocation.x
        let yDifference = frameLocation.y - cutImageManager.centerLocation.y
        let imagePosition = CGPoint(x: cutImageManager.imagePosition.x + xDifference, y: cutImageManager.imagePosition.y + yDifference)
        
        let previousImageSize = cutImageManager.imageSize
        let zoomDifference = newZoomScale / cutImageManager.zoomScale
        
        let newFrameXPoint: CGFloat = imagePosition.x + (frameLocation.x - imagePosition.x) * (imageSize.width / previousImageSize.width) * zoomDifference
        let newFrameYPoint: CGFloat = imagePosition.y + (frameLocation.y - imagePosition.y) * (imageSize.height / previousImageSize.height) * zoomDifference
        
        let resultXPoint: CGFloat = imagePosition.x + (frameLocation.x - newFrameXPoint)
        let resultYPoint: CGFloat = imagePosition.y + (frameLocation.y - newFrameYPoint)
        return CGPoint(x: resultXPoint, y: resultYPoint)
    }
    
    private func updatePosition(initialLocation: CGPoint, initialSize: CGSize, newSize: CGSize, viewSize: CGSize, zoomDifference: CGFloat) -> CGPoint{
        let frameLocation = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        let xDifference = frameLocation.x - cutImageManager.centerLocation.x
        let yDifference = frameLocation.y - cutImageManager.centerLocation.y
        let newPosition = CGPoint(x: initialLocation.x + xDifference, y: initialLocation.y + yDifference)

        let newFrameXPoint: CGFloat = newPosition.x + (frameLocation.x - newPosition.x) * (newSize.width / initialSize.width)
        let newFrameYPoint: CGFloat = newPosition.y + (frameLocation.y - newPosition.y) * (newSize.height / initialSize.height)
        
        let resultXPoint: CGFloat = newPosition.x + (frameLocation.x - newFrameXPoint)
        let resultYPoint: CGFloat = newPosition.y + (frameLocation.y - newFrameYPoint)
        
        return CGPoint(x: resultXPoint, y: resultYPoint)
    }
    
    private func updateStickerSize(initialSize: CGSize, frameSize: CGSize, newFrameSize: CGSize, newZoomScale: CGFloat) -> CGSize {
        let scaleWidth = initialSize.width / frameSize.width
        let scaleHeight = initialSize.height / frameSize.height
        
        let newWidth = newFrameSize.width * scaleWidth
        let newHeight = newFrameSize.height * scaleHeight
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    private func imageSize(imageSize: CGSize, viewSize: CGSize) -> CGSize{
        if cutImageManager.isHorizontalDegree(){
            let widthRatio = viewSize.width / imageSize.height
            let heightRatio = viewSize.height / imageSize.width
            let scale = min(widthRatio, heightRatio)
            
            return CGSize(
                width: imageSize.width * scale,
                height: imageSize.height  * scale
            )
        } else {
            let widthRatio = viewSize.width / imageSize.width
            let heightRatio = viewSize.height / imageSize.height
            let scale = min(widthRatio, heightRatio)
            
            print("imageSize", CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            ))
            
            return CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )
        }
    }
    
    private func calculateNewZoomScale(newSize: CGSize, viewSize: CGSize) -> CGFloat {
        let newFrameSize = cutImageManager.imageSize(imageSize: CGSize(width: cutImageManager.frameWidth, height: cutImageManager.frameHeight), viewSize: viewSize)
        
        let originImageWidth = cutImageManager.imageSize.width * cutImageManager.zoomScale
        let originImageHeight = cutImageManager.imageSize.height * cutImageManager.zoomScale
        // originalimage 크기에서 frame의 비율을 구한다 (1)
        let scaleWidth = cutImageManager.frameWidth / originImageWidth
        let scaleHeight = cutImageManager.frameHeight / originImageHeight
        // 새로운 이미지에 zoomscale 적용한다
        let newImageWidth = newSize.width * cutImageManager.zoomScale
        let newImageHeight = newSize.height * cutImageManager.zoomScale
        
        var newZoomScale: CGFloat = 1.0
        // 현재 frame 사이즈 기준으로 새로운 이미지의 크기를 맞춘다
        if newFrameSize.width > newFrameSize.height{
            newZoomScale = cutImageManager.zoomScale * (newFrameSize.width / (newImageWidth * scaleWidth))
        } else {
            newZoomScale = cutImageManager.zoomScale * (newFrameSize.height / (newImageHeight * scaleHeight))
        }
        
        newZoomScale = max(1.0, newZoomScale)
        
        return newZoomScale
    }

}
