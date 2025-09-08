//
//  View+Extension.swift
//  iCamera
//
//  Created by 홍승아 on 10/23/24.
//

import SwiftUI

extension View {
  func hidden(_ shouldHide: Bool) -> some View {
    self.opacity(shouldHide ? 0 : 1)
  }
  
  func roundedBackground(
    cornerRadius: CGFloat = .defaultCornerRadius,
    strokeColor: Color = .black,
    lineWidth: CGFloat = 1,
    fillColor: Color = .white
  ) -> some View {
    self.modifier(RoundedBackgroundModifier(
      cornerRadius: cornerRadius,
      strokeColor: strokeColor,
      lineWidth: lineWidth,
      fillColor: fillColor
    ))
  }
  
  func grayGridentBackground() -> some View {
    self.modifier(GrayGradientBackgroundModifier())
  }
  
  func navigationBar(
    _ viewType: PrimaryNavigationBar.ViewType,
    onLeadingButtonTap: (() -> Void)? = nil,
    trailingButtonType: PrimaryNavigationBar.ButtonType? = nil,
    onTrailingButtonTap: (() -> Void)? = nil,
    onCenterButtonTap: (() -> Void)? = nil
  ) -> some View {
    self
      .navigationBarHidden(true)
      .safeAreaInset(edge: .top) {
        PrimaryNavigationBar(
          viewType: viewType,
          onLeadingButtonTap: onLeadingButtonTap,
          trailingButtonType: trailingButtonType,
          onTrailingButtonTap: onTrailingButtonTap,
          onCenterButtonTap: onCenterButtonTap
        )
      }
  }
}
