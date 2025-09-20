//
//  Colors.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import SwiftUI

extension Color {
  static let skyBlue: Color = .init(red: 219, green: 248, blue: 255)
  static let titleBlack: Color = .init(red: 48, green: 48, blue: 48)
  static let silver: Color = .init(red: 201, green: 201, blue: 194)
  static let titleGray: Color = .init(red: 51, green: 51, blue: 51)
  static let sliderSliver: Color = .init(red: 235, green: 235, blue: 235)
  static let calendarRed: Color = .init(red: 220, green: 67, blue: 67)
  
  init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
    self = Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha)
  }
}
