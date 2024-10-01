//
//  MenuButtonView.swift
//  iCamera
//
//  Created by 홍승아 on 9/22/24.
//

import SwiftUI
import Combine

struct MenuButtonView: View {
    @Binding var menuButton: MenuButton
    
    @ObservedObject var buttonManager: MenuButtonManager
    
    var body: some View {
        ZStack{
            let isSelected = menuButton.isSelected
            let backgroundImage = isSelected ? "selected_menu_button" : "menu_button"
            let textColor: Color = isSelected ? Colors.titleGray : .white
            Image(backgroundImage)
                .resizable()
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Text(menuButton.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(textColor)
                    Spacer()
                }
                Spacer()
            }
            .onTapGesture {
                buttonManager.buttonClicked.send(menuButton.type)
            }
        }
    }
}
