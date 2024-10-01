//
//  MenuButtonManager.swift
//  iCamera
//
//  Created by 홍승아 on 9/30/24.
//

import SwiftUI
import Combine

struct MenuButton: Hashable{
    enum ButtonType: Int{
        case filter, sticker, frame, text
    }
    var type: ButtonType
    var isSelected: Bool = false
    var title: String {
        switch type {
        case .filter:
            return "Filter"
        case .sticker:
            return "Sticker"
        case .frame:
            return "Frame"
        case .text:
            return "Text"
        }
    }
}

class MenuButtonManager: ObservableObject{
    @Published var menuButtons = [ MenuButton(type: .filter, isSelected: true),
                            MenuButton(type: .sticker),
                            MenuButton(type: .frame),
                            MenuButton(type: .text)]
    var buttonClicked = PassthroughSubject<MenuButton.ButtonType, Never>()
    
    var cancellables = Set<AnyCancellable>()
    
    func setSelected(_ selectedIndex: Int){
        for index in menuButtons.indices{
            menuButtons[index].isSelected = false
        }
        menuButtons[selectedIndex].isSelected = true
    }
    
    func isSelected(_ type: MenuButton.ButtonType) -> Bool{
        return menuButtons[type.rawValue].isSelected
    }
}
