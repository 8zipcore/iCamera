//
//  TextMenuView.swift
//  iCamera
//
//  Created by 홍승아 on 10/20/24.
//

import SwiftUI

struct TextMenuView: View {
    
    @StateObject var textManager: TextManager
    
    @State private var alignmentImageStringArray = ["center_alignment", "leading_alignment", "trailing_alignment"]
    @State private var currentAlignmentIndex = 0
    
    var body: some View {
        HStack(spacing: 20){
            Button("Aa"){
                textManager.setCurrentTextMenu(.font)
            }
            .foregroundStyle(.black)
            
            Button(action: {
                // textManager.setCurrentTextMenu(.alignment)
                currentAlignmentIndex = (currentAlignmentIndex + 1) % 3
            }) {
                Image(alignmentImageStringArray[currentAlignmentIndex])
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .foregroundStyle(.black)
            
            Button(action: {
                textManager.setCurrentTextMenu(.color)
            }){
                Image("color")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .foregroundColor(.red)
        }
    }
}

#Preview {
    TextMenuView(textManager: TextManager())
}
