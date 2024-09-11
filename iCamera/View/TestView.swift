//
//  TestView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Color.white // 배경색 설정

                Text("Top Left")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .offset(x: 0, y: 0) // (0, 0) 좌표에 위치
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading) // 전체 공간 사용
            }
        }
    }
}

#Preview {
    TestView()
}
