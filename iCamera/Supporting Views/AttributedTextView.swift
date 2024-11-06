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
    var onSizeChange: (CGSize) -> Void
    
    @State private var textViewSize: CGSize = .zero
    @State private var backgroundViewSizeArray: [CGSize] = []
    @State private var lastTextViewHeight: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            ZStack{
                ForEach(backgroundViewSizeArray.indices, id: \.self){ index in
                    Rectangle()
                        .fill(textData.backgroundColor)
                        .frame(width: backgroundViewSizeArray[index].width, height: backgroundViewSizeArray[index].height)
                        .position(x: viewWidth / 2, y: (viewHeight / 2) + (backgroundViewSizeArray[index].height * multiple(index: index)))
                }
                
                CustomTextView(textData: $textData, 
                               onTextChange: { onTextChange($0) },
                               onSizeChange: { textViewSize = $0; onSizeChange($0) })
                .frame(height: textViewSize.height)
                    .position(x: viewWidth / 2, y: viewHeight / 2)
                    .onChange(of: textViewSize){ newSize in
                        if backgroundViewSizeArray.count == 0 {
                            backgroundViewSizeArray.append(newSize)
                            lastTextViewHeight = newSize.height
                            return
                        }
                        
                        let lastIndex = backgroundViewSizeArray.count - 1
                        let lineHeight = backgroundViewSizeArray.first?.height ?? 18

                        if lastTextViewHeight < newSize.height {
                            backgroundViewSizeArray.append(CGSize(width: newSize.width, height: lineHeight))
                            // print("append")
                        } else if lastTextViewHeight > newSize.height {
                            let lineNumber = Int(ceil(newSize.height / lineHeight))
                            for _ in lineNumber..<backgroundViewSizeArray.count {
                                backgroundViewSizeArray.removeLast()
                            }
                        } else {
                            backgroundViewSizeArray[lastIndex].width = newSize.width
                        }
                        if backgroundViewSizeArray.count == 1 && newSize.width == 0 {
                            backgroundViewSizeArray.removeLast()
                        }
                        lastTextViewHeight = newSize.height
                    }
            }
        }
    }
    
    private func multiple(index: Int) -> CGFloat{
        let centerIndex = backgroundViewSizeArray.count % 2 == 0 ?
        CGFloat(backgroundViewSizeArray.count - 1) / 2 : CGFloat(backgroundViewSizeArray.count / 2)
        return CGFloat(index) - centerIndex
    }
}

struct CustomTextView: UIViewRepresentable {
    @Binding var textData: TextData
    var textContainerInset: UIEdgeInsets = .zero
    var textViewWidth: CGFloat = .zero
    var onTextChange: (String) -> Void
    var onSizeChange: (CGSize) -> Void
    var lineHeight: CGFloat = .zero

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.setAttributedString(from: textData)
        print("text : ", textData.text)
        textView.font = textData.textFont.font
        textView.textAlignment = textData.textAlignment
        textView.delegate = context.coordinator
        textView.textContainerInset = textContainerInset
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.setAttributedString(from: textData)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // 가로로 커지지않게
        var textViewSize = uiView.sizeThatFits(CGSize(width: min(uiView.bounds.width, textViewWidth), height: .infinity))
        if let lineHeight = uiView.font?.lineHeight {
            textViewSize.width = uiView.getWidthOfLine(line: Int(textViewSize.height / lineHeight) - 1)
        }
        onSizeChange(textViewSize)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView

        init(_ parent: CustomTextView) {
            self.parent = parent
        }

        // 텍스트 변경 시 바인딩된 값 업데이트
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async{
                self.parent.textData.text = textView.text
                self.parent.onTextChange(textView.text)
            }
        }
    }
}

struct NonEditableCustomTextView: UIViewRepresentable {
    var textData: TextData
    var updateData: ([CGSize], CGSize) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = textData.textFont.font
        textView.textAlignment = textData.textAlignment
        textView.setAttributedString(from: textData)
        textView.textContainerInset = .zero
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.setAttributedString(from: textData)
        DispatchQueue.main.async{
            if let lineHeight = uiView.font?.lineHeight {
                let textViewSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .infinity))
                let lineNumber = Int(textViewSize.height / lineHeight)
                var backgroundViewSizeArray: [CGSize] = []
                for line in 0..<lineNumber{
                    let lineWidth = uiView.getWidthOfLine(line: line)
                    backgroundViewSizeArray.append(CGSize(width: lineWidth, height: round(lineHeight)))
                }
                updateData(backgroundViewSizeArray, textViewSize)
            }
        }
    }
}

extension UITextView{
    func getWidthOfLine(line: Int) -> CGFloat {
        let layoutManager = self.layoutManager
        let textStorage = self.textStorage

        // 해당 줄의 시작과 끝 범위를 찾기
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: 0, length: textStorage.length), actualCharacterRange: nil)

        var currenLine: Int = 0
        var width: CGFloat = 0

        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (_, usedRect, _, range, stop) in
            if currenLine == line {
                width = usedRect.width
                stop.pointee = true
            }
            currenLine += 1
        }
        return width
    }
    
    func setAttributedString(from textData: TextData) {
        let attributedString = NSMutableAttributedString(string: textData.text)
        let range = NSRange(location: 0, length: textData.text.count)

        attributedString.addAttribute(.foregroundColor, value: UIColor(textData.textColor), range: range)
        attributedString.addAttribute(.font, value: textData.textFont.font, range: range)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textData.textAlignment
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        self.attributedText = attributedString
    }
}
