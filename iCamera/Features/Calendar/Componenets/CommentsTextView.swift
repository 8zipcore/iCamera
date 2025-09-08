//
//  CommentsTextView.swift
//  iCamera
//
//  Created by 홍승아 on 12/27/24.
//

import SwiftUI

struct CommentsTextView: UIViewRepresentable {
    @Binding var textData: TextData
    var textContainerInset: UIEdgeInsets = .zero
    var textViewWidth: CGFloat = .zero
    var onTextChange: (String) -> Void
    var onSizeChange: (CGSize) -> Void
    var onCursorChange: ((CGPoint,CGPoint)) -> Void
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
        var parent: CommentsTextView

        init(_ parent: CommentsTextView) {
            self.parent = parent
        }

        // 텍스트 변경 시 바인딩된 값 업데이트
        func textViewDidChange(_ textView: UITextView) {
            self.parent.textData.text = textView.text
            self.parent.onTextChange(textView.text)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // 10ms 지연
                if let selectedRange = textView.selectedTextRange {
                    let caretRect = textView.caretRect(for: selectedRange.start)
                    
                    // 텍스트뷰 기준 커서 좌표
//                    print("Caret Rect in TextView: \(caretRect.minX) \(caretRect.minY)")
                    
                    // 화면 전체 기준 커서 좌표
                    let globalCaretRect = textView.convert(caretRect, to: nil)
//                    print("Caret Rect in Window: \(globalCaretRect.minX) \(globalCaretRect.minY)")
                    
                    self.parent.onCursorChange((CGPoint(x: caretRect.minX, y: caretRect.maxY), CGPoint(x: globalCaretRect.minX, y: globalCaretRect.minY)))
                }
            }
        }
    }
}
