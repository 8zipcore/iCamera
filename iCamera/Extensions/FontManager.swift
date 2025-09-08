//
//  FontManager.swift
//  iCamera
//
//  Created by 홍승아 on 11/13/24.
//

import SwiftUI

class FontManager{
    enum Font: Int, CaseIterable{
        case myungjo
        case LiGothic
        case Helvetica
        case Avenir
        case Georgia
        case SDGothic
        case NotoSans
        case NanumGothic
        case IBMPlex
        case Karla
    }
    
    func fontName(_ font: Font) -> String{
        switch font{
        case .myungjo:
            return "Apple Myungjo"
        case .LiGothic:
            return "Apple LiGothic"
        case .Helvetica:
            return "Helvetica Neue"
        case .Avenir:
            return "Avenir"
        case .Georgia:
            return "Georgia"
        case .SDGothic:
            return "SD Gothic Neo Font"
        case .NotoSans:
            return "NotoSansKR-Regular"
        case .NanumGothic:
            return "NanumGothicCoding-Regular"
        case .IBMPlex:
            return "IBMPlexSansKR-Regular"
        case .Karla:
            return "Karla-Medium"
        }
    }
    
    func fontNameToString(_ font: Font) -> String{
        switch font{
        case .myungjo:
            return "Myungjo"
        case .LiGothic:
            return "LiGothic"
        case .Helvetica:
            return "Helvetica"
        case .Avenir:
            return "Avenir"
        case .Georgia:
            return "Georgia"
        case .SDGothic:
            return "SDGothic"
        case .NotoSans:
            return "NotoSans"
        case .NanumGothic:
            return "NanumGothic"
        case .IBMPlex:
            return "IBMPlex"
        case .Karla:
            return "Karla"
        }
    }
    
    func fontToUIFont(_ font: Font, size: CGFloat) -> UIFont{
        let fontName = fontName(font)
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
