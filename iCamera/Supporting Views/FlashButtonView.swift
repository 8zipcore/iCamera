//
//  FlashButtonView.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import SwiftUI

struct FlashButtonView: View {
    
    @State var title: String
    @State var imageWidth: CGFloat
    
    var body: some View {
        
        let cornerRadius: CGFloat = 20
        
        HStack(spacing: 0){
            Image("flash")
                .resizable()
                .frame(width: imageWidth, height: imageWidth)
                .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 5))
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .padding(.trailing, 7)
        }
        .background(
            CustomRoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black, lineWidth: 1)
                .background(.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        )
    }
}

#Preview {
    FlashButtonView(title: "Auto", imageWidth: 20)
}
