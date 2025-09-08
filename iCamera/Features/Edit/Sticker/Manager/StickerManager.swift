//
//  StickerManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/3/24.
//

import SwiftUI
import Combine

class StickerManager: ObservableObject{
    var addButtonClicked = PassthroughSubject<Sticker, Never>()
    var buttonClicked = PassthroughSubject<EditStickerButtonData, Never>()
    
    @Published var stickerArray: [Sticker] = []
    
    var editStickerButtonArray: [EditStickerButton] = []
    
    var selectedSticker: Sticker?
    var isFirstDrag = true
    
    init(){
        editStickerButtonArray = EditStickerButtonType.allCases.map{ type in
            return EditStickerButton(type: type)
        }
    }
    
    func addSticker(_ sticker: Sticker){
        stickerArray.indices.forEach{ stickerArray[$0].isSelected = false }
        stickerArray.append(sticker)
        selectedSticker = sticker
    }
    
    func removeSticker(_ id: UUID){
        if let index = stickerArray.firstIndex(where: { $0.id == id }) {
            stickerArray.remove(at: index)
            selectedSticker = nil
        }
    }
    
    func updateSticker(_ sticker: Sticker){
        if let index = stickerArray.firstIndex(where: {$0.id == sticker.id }){
            stickerArray[index] = sticker
            selectedSticker = sticker
        }
    }
    
    func updateStickerLocation(id: UUID, location: CGPoint){
        if let index = stickerArray.firstIndex(where: {$0.id == id }){
            stickerArray[index].location = location
            selectedSticker = stickerArray[index]
        }
    }
    
    func selectSticker(index: Int){
        if stickerArray[index].isSelected{ return }
        stickerArray.indices.forEach{ stickerArray[$0].isSelected = false }
        stickerArray[index].isSelected = true
        selectedSticker = stickerArray[index]
    }
    
    func deselectAll(){
        stickerArray.indices.forEach{ stickerArray[$0].isSelected = false }
    }
    
    func updateSticker(sticker: Sticker, size: CGSize, location: CGPoint) -> Sticker{
        var sticker = sticker
        sticker.size = size
        sticker.location = location
        return sticker
    }
}
