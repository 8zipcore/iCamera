//
//  LaunchView.swift
//  iCamera
//
//  Created by 홍승아 on 12/5/24.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            ZStack{
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white, location: 0.2),
                        .init(color: Colors.silver, location: 1.0)
                    ]),
                    startPoint: .top, // 시작점
                    endPoint: .bottom // 끝점
                )
                let imageWidth = viewWidth * 0.35
                
                Image("logo")
                    .resizable()
                    .frame(width: imageWidth, height: imageWidth)
                    .position(x: viewWidth / 2, y: viewHeight / 2)
                
                Text("iCamera")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.black)
                    .position(x: viewWidth / 2, y: viewHeight)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LaunchView()
}
