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
                        .init(color: .white, location: 0.4),
                        .init(color: Colors.silver, location: 1.0)
                    ]),
                    startPoint: .top, // 시작점
                    endPoint: .bottom // 끝점
                )
                VStack(spacing: 0){
                    Spacer()
                    HStack(spacing: 0){
                        Spacer()
                        Image("blue_circle")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                            .padding(.bottom, -10)
                            .padding(.trailing, -2)
                    }
                    Text("iCamera")
                        .font(.system(size: 45, weight: .medium))
                    Spacer()
                }
                .frame(width: viewWidth * 0.5)
                .position(x: viewWidth / 2, y: viewHeight / 3)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LaunchView()
}
