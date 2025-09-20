//
//  GradientRectangleView.swift
//  iCamera
//
//  Created by 홍승아 on 10/30/24.
//

import SwiftUI

struct GradientRectangleView: View {
  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(
          gradient: Gradient(stops: [
            .init(color: .white, location: 0.05),
            .init(color: .silver, location: 1.0)
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .ignoresSafeArea()
  }
}

#Preview {
  GradientRectangleView()
}
