//
//  StickerView.swift
//  iCamera
//
//  Created by 홍승아 on 10/3/24.
//

import SwiftUI

struct StickerView: View {
    var index: Int
    var sticker: Sticker
    
    @StateObject var stickerManager: StickerManager
    
    @State private var lastAngle: Angle = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let imageWidth = sticker.size.width
            let imageHeight = sticker.size.height
            
            ZStack{
                Image(uiImage: sticker.image)
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
                            ZStack{
                                Image("xmark_button")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .position(x: x, y: y)
                            .onTapGesture{
                                stickerButtonTapped(EditStickerButtonData(type: type, location: .zero))
                            }
                        } else if type == .resize {
                            ZStack{
                                Image("resize_button")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .position(x: x, y: y)
                            .gesture(
                                DragGesture()
                                    .onChanged{ value in
                                        stickerButtonTapped(EditStickerButtonData(type: type, location: value.location))
                                    }
                            )
                        } else {
                            ZStack{
                                Circle()
                                    .fill(.white)
                                    .frame(width: 10, height: 10)
                            }
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                            .position(x: x, y: y)
                            .gesture(
                                DragGesture()
                                    .onChanged{ value in
                                        stickerButtonTapped(EditStickerButtonData(type: type, location: value.location))
                                    }
                            )
                        }
                    }
                }
            }
            .rotationEffect(sticker.angle)
            .gesture(
                SimultaneousGesture(
                    RotationGesture()
                        .onChanged { value in
                            stickerManager.stickerArray[index].angle = lastAngle + value
                        }
                        .onEnded{ _ in
                            lastAngle = stickerManager.stickerArray[index].angle
                        },
                    DragGesture()
                        .onChanged{ value in
                            if stickerManager.isFirstDrag{
                                stickerManager.selectSticker(index: index)
                                stickerManager.isFirstDrag = false
                            }
                            let newLocation = CGPoint(x: sticker.location.x + value.translation.width, y: sticker.location.y + value.translation.height)
                            stickerManager.updateStickerLocation(id: sticker.id, location: newLocation)
                        }
                        .onEnded{ _ in
                            stickerManager.isFirstDrag = true
                        }
                )
            )
        }
    }
    
    private func stickerButtonTapped(_ data: EditStickerButtonData){
        // let initialSize = sticker.image.size
        let currentSize = sticker.size
        var newSize = CGSize(width: data.location.x, height: data.location.y)
        
        let location = sticker.location
        var newLocation: CGPoint = .zero
        
        let scale = EditStickerButton(type: data.type).position
        
        switch data.type{
        case .remove:
            stickerManager.removeSticker(sticker.id)
            break
        case .resize:
            let scale = max(newSize.width / currentSize.width, newSize.height / currentSize.height)
            newSize = CGSize(width: currentSize.width * scale, height: currentSize.height * scale)
            break
        case .trailing: fallthrough
        case .bottom:
            let widthDifferenceValue = (newSize.width - currentSize.width) * scale.x
            let heightDifferenceValue = (newSize.height - currentSize.height) * scale.y
            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
            newLocation = CGPoint(x: location.x + widthDifferenceValue / 2, y: location.y + heightDifferenceValue / 2)
        case .top: fallthrough
        case .leading:
            let widthDifferenceValue = newSize.width * scale.x
            let heightDifferenceValue = newSize.height * scale.y
            newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
            newLocation = CGPoint(x: location.x - widthDifferenceValue / 2, y: location.y - heightDifferenceValue / 2)
        }
        
        if data.type == .remove { return }
        
        let minSize = CGSize(width: 50, height: 50)
        
        var sticker = sticker
        let width = max(newSize.width, minSize.width)
        let height = max(newSize.height, minSize.height)
        sticker.size = CGSize(width: width, height: height)
        
        if data.type != .resize && newSize.width > minSize.width && newSize.height > minSize.height {
            print(newSize)
            sticker.location = newLocation
        }
        stickerManager.updateSticker(sticker)
    }
}
