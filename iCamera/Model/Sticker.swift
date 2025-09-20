//
//  Sticker.swift
//  iCamera
//
//  Created by 홍승아 on 11/16/24.
//

import UIKit
import SwiftUI

struct Sticker {
  var id = UUID()
  var image: UIImage
  var location: CGPoint
  var size: CGSize
  var angle: Angle
  var isSelected: Bool
}

enum EditStickerButtonType: CaseIterable {
  case remove
  case top, bottom, leading, trailing
  case resize
}

struct EditStickerButtonData {
  var type: EditStickerButtonType
  var location: CGPoint
}

struct EditStickerButton: Hashable {
  var type: EditStickerButtonType
  
  var position: CGPoint {
    switch type {
    case .remove:
      return CGPoint(x: -1, y: -1)
    case .top:
      return CGPoint(x: 0, y: -1)
    case .leading:
      return CGPoint(x: -1, y: 0)
    case .trailing:
      return CGPoint(x: 1, y: 0)
    case .bottom:
      return CGPoint(x: 0, y: 1)
    case .resize:
      return CGPoint(x: 1, y: 1)
    }
  }
}
