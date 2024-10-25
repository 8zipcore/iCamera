//
//  SelectColorView.swift
//  iCamera
//
//  Created by 홍승아 on 10/20/24.
//

import SwiftUI

struct SelectColorView: View {
    
    @StateObject var textManager: TextManager
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                Image("text_color")
                    .resizable()
                    .frame(width: 30, height: 30)
                ScrollView(.horizontal){
                    HStack(spacing: 10){
                        ForEach(textManager.textColor, id: \.self){ color in
                            Circle()
                                .fill(color)
                                .frame(width: 25, height: 25)
                                .onTapGesture {
                                    textManager.setTextColor(color: color)
                                }
                        }
                    }
                }
            }
            
            HStack(spacing: 15){
                Image("background_text_color")
                    .resizable()
                    .frame(width: 30, height: 30)
                ScrollView(.horizontal){
                    HStack(spacing: 10){
                        ForEach(textManager.backgroundColor, id: \.self){ color in
                            Circle()
                                .fill(color)
                                .frame(width: 25, height: 25)
                                .onTapGesture {
                                    textManager.setBackgroundColor(color: color)
                                }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.clear)
    }
}

#Preview {
    SelectColorView(textManager: TextManager())
}
