//
//  UITextView+Extension.swift
//  iCamera
//
//  Created by 홍승아 on 9/12/25.
//

import UIKit

extension UITextView {
  func getWidthOfLine(line: Int) -> CGFloat {
    let layoutManager = self.layoutManager
    let textStorage = self.textStorage
    
    self.layoutManager.ensureLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length))
    
    // 해당 줄의 시작과 끝 범위를 찾기
    let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: 0, length: textStorage.length), actualCharacterRange: nil)
    
    var currentLine: Int = 0
    var width: CGFloat = 0
    
    layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (_, usedRect, _, range, stop) in
      if currentLine == line {
        width = usedRect.width
        stop.pointee = true
      }
      currentLine += 1
    }
    
    return width
  }
  
  func getWidthOfLineArray(lineNumber: Int) -> [CGFloat] {
    let layoutManager = self.layoutManager
    let textStorage = self.textStorage
    
    self.layoutManager.ensureLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length))
    
    // 해당 줄의 시작과 끝 범위를 찾기
    let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: 0, length: textStorage.length), actualCharacterRange: nil)
    
    var currentLine: Int = 0
    var widthArray: [CGFloat] = []
    
    layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (_, usedRect, _, range, stop) in
      if currentLine == lineNumber + 1 {
        stop.pointee = true
      }
      widthArray.append(usedRect.width)
      currentLine += 1
    }
    
    return widthArray
  }
  
  func setAttributedString(from textData: TextData) {
    let selectedRange = self.selectedRange
    
    // NSString으로 변환하여 UTF-16 기반으로 NSRange 생성
    let nsString = textData.text as NSString
    let range = NSRange(location: 0, length: nsString.length)
    
    // Attributed String 생성
    let attributedString = NSMutableAttributedString(string: nsString as String)
    
    attributedString.addAttribute(.foregroundColor, value: UIColor(textData.textColor), range: range)
    attributedString.addAttribute(.font, value: textData.textFont.uiFont, range: range)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textData.textAlignment
    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
    
    self.attributedText = attributedString
    
    self.selectedRange = selectedRange
  }
}
