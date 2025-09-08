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
    @StateObject var editManager: EditManager
    
    var editImageViewPositionArray: [CGPoint]
    
    @State private var lastAngle: Angle = .zero
    @State private var buttonWidth: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            let imageWidth = sticker.size.width
            let imageHeight = sticker.size.height
            
            ZStack{
                Image(uiImage: sticker.image)
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .position(x: viewWidth / 2, y: viewHeight / 2)
                
                if sticker.isSelected{
                    Rectangle()
                        .stroke(.white, lineWidth: 2.0)
                        .frame(width: imageWidth, height: imageHeight)
                        .position(x: viewWidth / 2, y: viewHeight / 2)
                    
                    ForEach(stickerManager.editStickerButtonArray, id: \.self){ editStickerButton in
                        let x = (viewWidth / 2) + (imageWidth / 2) * editStickerButton.position.x
                        let y = (viewHeight / 2) + (imageHeight / 2) * editStickerButton.position.y
                        
                        let type = editStickerButton.type
                        
                        if type == .remove {
                            ZStack{
                                Image("xmark_button")
                                    .resizable()
                                    .frame(width: buttonWidth, height: buttonWidth)
                            }
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .position(x: x, y: y)
                            .onTapGesture{
                                stickerButtonTapped(data: EditStickerButtonData(type: type, location: .zero))
                            }
                        } else if type == .resize {
                            ZStack{
                                Image("resize_button")
                                    .resizable()
                                    .frame(width: buttonWidth, height: buttonWidth)
                            }
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .position(x: x, y: y)
                            .gesture(
                                DragGesture()
                                    .onChanged{ value in
                                        stickerButtonTapped(data: EditStickerButtonData(type: type, location: value.location))
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
                                        stickerButtonTapped(data: EditStickerButtonData(type: type, location: value.location))
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
                            var newLocation = CGPoint(x: sticker.location.x + value.translation.width, y: sticker.location.y + value.translation.height)
                            // StickerView 드래그 범위 제한
                            newLocation = updateStickerViewPosition(stickerSize: sticker.size, location: newLocation)
                
                            if stickerManager.isFirstDrag{
                                stickerManager.selectSticker(index: index)
                                editManager.selectSticker.send()
                                stickerManager.isFirstDrag = false
                            }

                            stickerManager.updateStickerLocation(id: sticker.id, location: newLocation)
                        }
                        .onEnded{ _ in
                            stickerManager.isFirstDrag = true
                        }
                )
            )
        }
    }
    
    private func stickerButtonTapped(data: EditStickerButtonData){
        // let initialSize = sticker.image.size
        let currentSize = sticker.size
        var newSize = CGSize(width: data.location.x, height: data.location.y)
        
        let location = sticker.location
        var newLocation: CGPoint = sticker.location
        
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
        
        /* 사이즈 조정할때 부모 뷰 크기 넘어가지 않게 */
        let updateLocation = updateStickerViewPosition(stickerSize: currentSize, location: newLocation)
        var updateSize = newSize
        
        if updateLocation.x != newLocation.x {
            updateSize.width = min(currentSize.width, newSize.width)
            if updateSize.width == currentSize.width {
                newLocation.x = sticker.location.x
            }
        }
        
        if updateLocation.y != newLocation.y  {
            updateSize.height = min(currentSize.height, newSize.height)
            if updateSize.height == currentSize.height {
                newLocation.y = sticker.location.y
            }
        }
        
        if data.type == .resize{
            let widthDifference = updateSize.width / currentSize.width
            let heightDifference = updateSize.height / currentSize.height
            let multiple = min(widthDifference, heightDifference)
            newSize = CGSize(width: currentSize.width * multiple, height: currentSize.height * multiple)
        } else{
            newSize = updateSize
        }
        
        let minSize = CGSize(width: 50, height: 50)
        var sticker = sticker
        sticker.size = CGSize(width: max(newSize.width, minSize.width), height: max(newSize.height, minSize.height))
        
        if data.type != .resize && newSize.width > minSize.width && newSize.height > minSize.height {
            sticker.location = newLocation
        }
        
        stickerManager.updateSticker(sticker)
    }
    
    private func updateStickerViewPosition(stickerSize: CGSize, location: CGPoint) -> CGPoint{
        var newLocation = location
        let viewWidth = stickerSize.width + buttonWidth
        let viewHeight = stickerSize.height + buttonWidth
        
        let stickerViewPositionArray = [CGPoint(x: newLocation.x - viewWidth / 2, y: newLocation.y - viewHeight / 2), CGPoint(x: newLocation.x + viewWidth / 2, y: newLocation.y + viewHeight / 2)]
       
        if stickerViewPositionArray[0].x < editImageViewPositionArray[0].x {
            newLocation.x = editImageViewPositionArray[0].x + viewWidth / 2
        } else if stickerViewPositionArray[1].x > editImageViewPositionArray[1].x {
            newLocation.x = editImageViewPositionArray[1].x - viewWidth / 2
        }
        
        if stickerViewPositionArray[0].y < editImageViewPositionArray[0].y {
            newLocation.y = editImageViewPositionArray[0].y + viewHeight / 2
        } else if stickerViewPositionArray[1].y > editImageViewPositionArray[1].y {
            newLocation.y = editImageViewPositionArray[1].y - viewHeight / 2
        }
        return newLocation
    }
}
