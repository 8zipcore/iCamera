//
//  StickerView.swift
//  iCamera
//
//  Created by 홍승아 on 10/3/24.
//

import SwiftUI

struct StickerView: View {
    
    var sticker: Sticker
    @ObservedObject var stickerManager: StickerManager
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            let imageWidth = sticker.size.width
            let imageHeight = sticker.size.height
            
            ZStack{
                Image("star_sticker")
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .position(x: imageWidth / 2, y: imageHeight / 2)
                
                if sticker.isSelected{
                   Rectangle()
                        .stroke(.white, lineWidth: 2.0)
                        .frame(width: imageWidth, height: imageHeight)
                        .position(x: imageWidth / 2, y: imageHeight / 2)
                    
                    ForEach(stickerManager.editStickerButtonArray, id: \.self){ editStickerButton in
                        let x = (imageWidth / 2) + (imageWidth / 2) * editStickerButton.position.x
                        let y = (imageHeight / 2) + (imageHeight / 2) * editStickerButton.position.y
                        
                        let type = editStickerButton.type
                        
                        if type == .remove {
                            Image("xmark_button")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .position(x: x, y: y)
                                .onTapGesture{
                                    stickerManager.buttonClicked.send(EditStickerButtonData(id: sticker.id, type: type, location: .zero))
                                }
                        } else if type == .resize {
                            Image("xmark_button")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .position(x: x, y: y)
                                .gesture(
                                    DragGesture()
                                        .onChanged{ value in
                                            stickerManager.buttonClicked.send(EditStickerButtonData(id: sticker.id, type: type, location: value.location))
                                        }
                                )
                        } else {
                            Circle()
                                .fill(.white)
                                .frame(width: 10, height: 10)
                                .position(x: x, y: y)
                                .gesture(
                                    DragGesture()
                                        .onChanged{ value in
                                            stickerManager.buttonClicked.send(EditStickerButtonData(id: sticker.id, type: type, location: value.location))
                                        }
                                )
                        }
                    }
                }
            }
        }
    }
}
