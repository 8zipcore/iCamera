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
        HStack(spacing: 25){
            Button(action:{
                textManager.setCurrentTextMenu(.font)
            }){
                Text("Aa")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.black)
            }
            .foregroundStyle(.black)
            
            Button(action: {
                textManager.setTextAlignment()
                currentAlignmentIndex = (currentAlignmentIndex + 1) % 3
            }) {
                Image(alignmentImageStringArray[currentAlignmentIndex])
                    .resizable()
                    .frame(width: 17, height: 17)
            }
            .foregroundStyle(.black)
            
            Button(action: {
                textManager.setCurrentTextMenu(.color)
            }){
                Image("color")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            .foregroundColor(.red)
        }
    }
}

#Preview {
    TextMenuView(textManager: TextManager())
}
