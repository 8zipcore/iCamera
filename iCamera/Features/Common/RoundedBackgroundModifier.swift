//
//  RoundedBackgroundModifier.swift
//  iCamera
//
//  Created by 홍승아 on 9/8/25.
//


import SwiftUI

struct RoundedBackgroundModifier: ViewModifier {
  var cornerRadius: CGFloat = .defaultCornerRadius
  var strokeColor: Color = .black
  var lineWidth: CGFloat = 1
  var fillColor: Color = .white
  
  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(strokeColor, lineWidth: lineWidth)
          .background(fillColor)
          .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      )
  }
}
