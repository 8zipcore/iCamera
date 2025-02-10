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
    var pixCropManager: PixCropManager
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            let viewSize = geometry.size
            ZStack{
/*
                Rectangle()
                    .stroke(.white, lineWidth: 1.0)
                    .frame(width: imageSize.width, height: imageSize.height)
                */
                
                ImageCropResultView(pixCropManager: pixCropManager, frame: CGRect(origin: .zero, size: viewSize))
                
                if let filteredImage = filterManager.applyFilters(to: image) {
                    ImageCropResultView(pixCropManager: pixCropManager, frame: CGRect(origin: .zero, size: viewSize), image: filteredImage, oppacity: filterManager.filterValue)
                }
                
                /* ⭐️ StickerView 시작 */
                ForEach(stickerManager.stickerArray.indices, id:\.self){ index in
                    let sticker = stickerManager.stickerArray[index]
                    let newSize = updateSize(size: sticker.size, viewSize: viewSize)
                    let newLocation = updatePosition(position: sticker.location, viewSize: viewSize)
                    let newSticker = stickerManager.updateSticker(sticker: sticker, size: newSize, location: newLocation)
                    StickerView(index: index, sticker: newSticker, stickerManager: stickerManager, editManager: EditManager(), editImageViewPositionArray: [])
                        .frame(width: newSize.width, height: newSize.height)
                        .position(newLocation)
                }
                /* ⭐️ StickerView 끝 (ForEach) */
                /* ⭐️ TextView 시작 */
                ForEach(textManager.textArray.indices, id: \.self){ index in
                    let text = textManager.setTextPlaceHolder(index: index)
                    let newSize = updateSize(size: text.size, viewSize: viewSize)
                    let newLocation = updatePosition(position: text.location, viewSize: viewSize)
                    let newText = textManager.updateText(text: text, size: newSize, location: newLocation)
                    TextView(index: index, textData: newText, textViewSize: newText.size, textManager: textManager, editManager: EditManager(), editImageViewPositionArray: [], backgroundViewSizeArray: newText.backgroundColorSizeArray)
//                        .frame(width: text.size.width, height: text.size.height)
                        .position(newLocation)
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    private func updateSize(size: CGSize, viewSize: CGSize) -> CGSize{
        let lastFrameSize = pixCropManager.maskSize
        let newFramSize = cutImageManager.imageSize(imageSize: lastFrameSize, viewSize: viewSize)
        let scale = min(newFramSize.width / lastFrameSize.width, newFramSize.height / lastFrameSize.height)
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    private func updatePosition(position: CGPoint, viewSize: CGSize) -> CGPoint{
        let lastCenter = pixCropManager.pixCropView.center
        let lastFrameSize = pixCropManager.maskSize
        let newFramSize = cutImageManager.imageSize(imageSize: lastFrameSize, viewSize: viewSize)
        let viewCenter = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        
        return CGPoint(
            x: viewCenter.x + (position.x - lastCenter.x) * (newFramSize.width / lastFrameSize.width),
            y: viewCenter.y + (position.y - lastCenter.y) * (newFramSize.height / lastFrameSize.height)
        )
    }
}
