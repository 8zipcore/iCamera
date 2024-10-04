//
//  StickerManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/3/24.
//

import SwiftUI
import Combine

enum EditStickerButtonType: CaseIterable{
    case remove
    // top, trailing-top, leading-center, trailing-center, leading-bottom, bottom
    case top, bottom, leading, trailing
    case resize
}

struct EditStickerButtonData{
    var id: UUID
    var type: EditStickerButtonType
    var location: CGPoint
}

struct EditStickerButton: Hashable{
    var type: EditStickerButtonType
    
    var position: CGPoint{
        switch type {
        case .remove:
            return CGPoint(x: -1, y: -1)
        case .top:
            return CGPoint(x: 0, y: -1)
        case .leading:
            return CGPoint(x: -1, y: 0)
        case .trailing:
            return CGPoint(x: 1, y: 0)
        case .bottom:
            return CGPoint(x: 0, y: 1)
        case .resize:
            return CGPoint(x: 1, y: 1)
        }
    }
}

struct Sticker {
    var id = UUID()
    var image: UIImage
    var location: CGPoint
    var size: CGSize
    var isSelected: Bool
}

class StickerManager: ObservableObject{
    
    var editStickerButtonArray: [EditStickerButton] = []
    
    @Published var stickerArray: [Sticker] = []
    
    var buttonClicked = PassthroughSubject<EditStickerButtonData, Never>()
    
    init(){
        editStickerButtonArray = EditStickerButtonType.allCases.map{ type in
            return EditStickerButton(type: type)
        }
    }
    
    func addSticker(_ sticker: Sticker){
        stickerArray.indices.forEach{ stickerArray[$0].isSelected = false }
        stickerArray.append(sticker)
    }
    
    func removeSticker(_ index: Int){
        stickerArray.remove(at: index)
    }
    
    func selectSticker(index: Int){
        var sticker = stickerArray[index]
        if sticker.isSelected{
            return
        }
        sticker.isSelected = true
        stickerArray.remove(at: index)
        addSticker(sticker)
    }
}
