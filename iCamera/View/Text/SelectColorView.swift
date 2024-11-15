//
//  SelectColorView.swift
//  iCamera
//
//  Created by 홍승아 on 10/20/24.
//

import SwiftUI

struct SelectColorView: View {
    
    @StateObject var textManager: TextManager
    
    @State private var textColor: [Color] = []
    @State private var backgroundColor: [Color] = [.clear]
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                Image("text_color")
                    .resizable()
                    .frame(width: 30, height: 30)
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 10){
                        ForEach(textColor, id: \.self){ color in
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
            
            HStack(spacing: 10){
                Image("background_text_color")
                    .resizable()
                    .frame(width: 30, height: 30)
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 10){
                        ForEach(backgroundColor, id: \.self){ color in
                            if color == .clear {
                                Circle()
                                    .stroke(.black, lineWidth: 1.0)
                                    .frame(width: 23.5, height: 23.5)
                                    .padding(.leading, 5)
                            } else {
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
        }
        .padding()
        .background(.clear)
        .onAppear{
            textColor =  [.black, .white, .red, .orange, .yellow, .green, .mint, .blue, .indigo, .pink, .cyan, .purple, .brown]
            textColor.forEach{
                backgroundColor.append($0)
            }
        }
    }
}
