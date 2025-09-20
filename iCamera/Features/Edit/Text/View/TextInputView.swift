//
//  TextInputView.swift
//  iCamera
//
//  Created by 홍승아 on 10/20/24.
//

import SwiftUI

struct TextInputView: View {
  @State var textData: TextData
  @StateObject var textManager: TextManager
  @State private var textInput: String = ""
  
  @State private var textViewSize: CGSize = .zero
  @StateObject private var keyboardObserver = KeyboardObserver()
  @FocusState private var isFocused: Bool
  
  @State private var textBackgroundSizes: [CGSize] = []
  
  var body: some View {
    GeometryReader { geometry in
      let viewWidth = geometry.size.width
      let viewHeight = geometry.size.height
      
      let barSize = CGSize(
        width: viewWidth,
        height: viewHeight * 0.05
      )
      let topPadding: CGFloat = 15
      let textViewMaxHeight: CGFloat = viewHeight - keyboardObserver.keyboardHeight - barSize.height
      VStack {
        AttributedTextView(
          textData: $textData,
          onTextChange: { textInput = $0 },
          updateData: {
            textBackgroundSizes = $0
            textViewSize = $1
          }
        )
        .focused($isFocused)
        .position(x: viewWidth * 0.9 / 2, y: textViewMaxHeight / 2)
        .frame(maxWidth: viewWidth * 0.9)
        .padding(.top, topPadding)
        .onAppear {
          isFocused = true
        }
        
        keyboardToolbar(barSize: barSize)
      }
      .background(Color.black.opacity(0.3))
      .ignoresSafeArea(edges: .bottom)
    }
    .onAppear {
      textInput = textManager.textInput()
    }
  }
}

extension TextInputView {
  @ViewBuilder
  private func keyboardToolbar(barSize: CGSize) -> some View {
    let buttonSize = CGSize(
      width: barSize.height * 0.75,
      height: barSize.height * 0.75
    )
    
    HStack {
      Button {
        textManager.textInputCancelButtonTapped.send(textData)
      } label: {
        Image("xmark_button")
          .resizable()
          .frame(width: buttonSize.width, height: buttonSize.height)
      }
      .padding(.leading, 10)
      
      Spacer()
      
      Button {
        textData.text = textInput
        textData.textBackgroundSizes = textBackgroundSizes
        textData.size = textViewSize
        textManager.textInputConfirmButtonTapped.send(textData)
      } label: {
        Image("confirm_button")
          .resizable()
          .frame(width: buttonSize.width, height: buttonSize.height)
      }
      .padding(.trailing, 10)
    }
    .frame(height: barSize.height)
    .padding(.bottom, keyboardObserver.keyboardHeight)
    .background(GradientRectangleView())
  }
}

