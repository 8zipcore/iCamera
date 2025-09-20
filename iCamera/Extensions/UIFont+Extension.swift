//
//  UIFont+Extension.swift
//  iCamera
//
//  Created by 홍승아 on 11/13/24.
//

import SwiftUI

enum AppFont: Int, CaseIterable {
  case myungjo
  case liGothic
  case helvetica
  case avenir
  case georgia
  case sdGothic
  case notoSans
  case nanumGothic
  case ibmPlex
  case karla
  case system
  
  var title: String {
    switch self {
    case .myungjo:
      return "Myungjo"
    case .liGothic:
      return "LiGothic"
    case .helvetica:
      return "Helvetica"
    case .avenir:
      return "Avenir"
    case .georgia:
      return "Georgia"
    case .sdGothic:
      return "SDGothic"
    case .notoSans:
      return "NotoSans"
    case .nanumGothic:
      return "NanumGothic"
    case .ibmPlex:
      return "IBMPlex"
    case .karla:
      return "Karla"
    default:
      return ""
    }
  }
  
  var name: String {
    switch self {
    case .myungjo:
      return "Apple Myungjo"
    case .liGothic:
      return "Apple LiGothic"
    case .helvetica:
      return "Helvetica Neue"
    case .avenir:
      return "Avenir"
    case .georgia:
      return "Georgia"
    case .sdGothic:
      return "SD Gothic Neo Font"
    case .notoSans:
      return "NotoSansKR-Regular"
    case .nanumGothic:
      return "NanumGothicCoding-Regular"
    case .ibmPlex:
      return "IBMPlexSansKR-Regular"
    case .karla:
      return "Karla-Medium"
    default:
      return ""
    }
  }
}

extension UIFont {
  convenience init(_ font: AppFont, size: CGFloat) {
    let base = UIFont(name: font.name, size: size) ?? UIFont.systemFont(ofSize: size)
    self.init(descriptor: base.fontDescriptor, size: size)
  }
}
