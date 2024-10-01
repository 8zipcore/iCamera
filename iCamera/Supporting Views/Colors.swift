//
//  Colors.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import SwiftUI

struct Colors{
    static let skyBlue = RGB(red: 219, green: 248, blue: 255)
    static let titleBlack = RGB(red: 48, green: 48, blue: 48)
    static let silver = RGB(red: 201, green: 201, blue: 194)
    static let titleGray = RGB(red: 51, green: 51, blue: 51)
}

func RGB(red: Double, green: Double, blue: Double) -> Color{
    return Color(red: red / 255, green: green / 255, blue: blue / 255)
}
