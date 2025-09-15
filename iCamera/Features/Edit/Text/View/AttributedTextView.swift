//
//  AttributedTextView.swift
//  iCamera
//
//  Created by 홍승아 on 10/23/24.
//

import SwiftUI
import UIKit

struct AttributedTextView: View {
  @Binding var textData: TextData
  var onTextChange: (String) -> Void
  var updateData: ([CGSize], CGSize) -> Void
  
  @State private var textViewSize: CGSize = .zero
  @State private var textBackgroundSizes: [CGSize] = []
  @State private var lastTextViewHeight: CGFloat = .zero
  
  var body: some View {
    GeometryReader { geometry in
      let viewWidth = geometry.size.width
      let viewHeight = geometry.size.height
      
      ZStack{
        ForEach(textBackgroundSizes.indices, id: \.self){ index in
          let backgroundViewSize = textBackgroundSizes[index]
          let position = backgroundArrayPosition(index: index, viewSize: geometry.size)
          
          Rectangle()
            .fill(textData.backgroundColor)
            .frame(width: backgroundViewSize.width, height: backgroundViewSize.height)
            .position(x: position.x, y: position.y)
        }
        
        CustomTextView(
          textData: $textData,
          onTextChange: { onTextChange($0) },
          onSizeChange: { textViewSize = $0 },
          updateData: { newArray, newSize in
            textBackgroundSizes = newArray
            textViewSize = newSize
            updateData(newArray, newSize)
          }
        )
        .frame(height: textViewSize.height)
        .position(x: viewWidth / 2, y: viewHeight / 2)
      }
    }
  }
  
  private func multiple(index: Int) -> CGFloat{
    let arrayCount = textBackgroundSizes.count
    let centerIndex = arrayCount % 2 == 0 ?
    CGFloat(arrayCount - 1) / 2 : CGFloat(arrayCount / 2)
    return CGFloat(index) - centerIndex
  }
  
  private func backgroundArrayPosition(index: Int, viewSize: CGSize) -> CGPoint{
    let size = textBackgroundSizes[index]
    var position: CGPoint = .zero
    switch textData.textAlignment {
    case .left:
      position.x = size.width / 2
    case .center:
      position.x = viewSize.width / 2
    case .right:
      position.x = viewSize.width  - size.width / 2
    default:
      break
    }
    position.y = (viewSize.height / 2) + (size.height * multiple(index: index))
    return position
  }
}

struct CustomTextView: UIViewRepresentable {
  @Binding var textData: TextData
  var textContainerInset: UIEdgeInsets = .zero
  var textViewWidth: CGFloat = .zero
  var onTextChange: (String) -> Void
  var onSizeChange: (CGSize) -> Void
  var updateData: ([CGSize], CGSize) -> Void
  var lineHeight: CGFloat = .zero
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = true
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.setAttributedString(from: textData)
    textView.font = textData.textFont.font
    textView.textAlignment = textData.textAlignment
    textView.delegate = context.coordinator
    textView.textContainerInset = textContainerInset
    textView.textContainer.lineBreakMode = .byWordWrapping
    textView.textContainer.maximumNumberOfLines = 0
    textView.tintColor = .black
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.setAttributedString(from: textData)
    uiView.font = textData.textFont.font
    uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    let lineHeight = textData.textFont.font.lineHeight
    let textViewSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .infinity))
    let lineNumber = Int(textViewSize.height / lineHeight)
      
    var textBackgroundSizes: [CGSize] = []
    for line in 0..<lineNumber{
      let lineWidth = uiView.getWidthOfLine(line: line)
      textBackgroundSizes.append(CGSize(width: lineWidth, height: round(lineHeight)))
    }
    DispatchQueue.main.async{
      updateData(textBackgroundSizes, textViewSize)
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextViewDelegate {
    var parent: CustomTextView
    var didSetInitialCursor = false
    
    init(_ parent: CustomTextView) {
      self.parent = parent
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
      if !didSetInitialCursor {
        let endPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
        didSetInitialCursor = true
      }
    }
    
    func textViewDidChange(_ textView: UITextView) {
      DispatchQueue.main.async{
        self.parent.textData.text = textView.text
        self.parent.onTextChange(textView.text)
      }
    }
  }
}
