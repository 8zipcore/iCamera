//
//  NonEditableCustomTextView.swift
//  iCamera
//
//  Created by 홍승아 on 9/12/25.
//

import SwiftUI

struct NonEditableCustomTextView: UIViewRepresentable {
  @Binding var textData: TextData
  var containerWidth: CGFloat
  var updateData: ([CGSize], CGSize) -> Void
  
  func makeUIView(context: Context) -> ResizableTextView {
    let textView = ResizableTextView()
    textView.isEditable = true
    textView.isSelectable = false
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.textContainer.widthTracksTextView = true
    textView.textContainer.lineBreakMode = .byWordWrapping
    textView.font = textData.textFont.uiFont
    textView.textAlignment = textData.textAlignment
    textView.setAttributedString(from: textData)
    textView.textContainerInset = .zero
    textView.clipsToBounds = true
    return textView
  }
  
  func updateUIView(_ uiView: ResizableTextView, context: Context) {
    uiView.setAttributedString(from: textData)
    uiView.font = textData.textFont.uiFont
    uiView.textAlignment = textData.textAlignment
    
    let lineHeight = textData.textFont.uiFont.lineHeight
    let textViewSize = uiView.sizeThatFits(
      CGSize(
        width: containerWidth,
        height: CGFloat.greatestFiniteMagnitude
      )
    )
    let lineNumber = Int(textViewSize.height / lineHeight)
    var textBackgroundSizes: [CGSize] = []
    
    uiView.getWidthOfLineArray(lineNumber: lineNumber).forEach{
      textBackgroundSizes.append(CGSize(width: $0, height: round(lineHeight)))
    }
    
    updateData(textBackgroundSizes, textViewSize)
  }
}

class ResizableTextView: UITextView {
  override var intrinsicContentSize: CGSize {
    let size = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    return CGSize(width: bounds.width, height: size.height)
  }
}
