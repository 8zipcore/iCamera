//
//  ListView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct ListView: View {
    
    @State var title: String
    @State var imageWidth: CGFloat
    
    var body: some View {
        HStack{
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            Image("arrow")
                .resizable()
                .frame(width: imageWidth, height: imageWidth)
            
            /*
            Button(action: action) {
                Image("arrow")
                    .resizable()
                    .frame(width: imageWidth, height: imageWidth)
            }
            */
        }
        .contentShape(Rectangle()) // Spacer도 터치 가능하게 해줌
    }
}

#Preview {
    ListView(title: "Camera", imageWidth: 15)
}
