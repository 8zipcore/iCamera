//
//  UIImage+Extension.swift
//  iCamera
//
//  Created by 홍승아 on 9/15/25.
//

import UIKit

extension UIImage {
  func fixOrientation() -> UIImage? {
    if imageOrientation == .up { return self }
    
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(in: CGRect(origin: .zero, size: size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return normalizedImage ?? self
  }
  
  func resized(to targetSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { _ in
        self.draw(in: CGRect(origin: .zero, size: targetSize))
    }
  }
}
