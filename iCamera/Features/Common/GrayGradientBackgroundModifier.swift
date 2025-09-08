//
//  GrayGradientBackgroundModifier.swift
//  iCamera
//
//  Created by 홍승아 on 9/8/25.
//

import SwiftUI

struct GrayGradientBackgroundModifier: ViewModifier {
  
  func body(content: Content) -> some View {
    content
      .background(
        LinearGradient(
          gradient: Gradient(stops: [
            .init(color: Colors.silver, location: 0.3),
            .init(color: .white, location: 0.5),
            .init(color: Colors.silver, location: 1.0)
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
  }
}
