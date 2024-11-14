//
//  TextInputView.swift
//  iCamera
//
//  Created by 홍승아 on 10/20/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct TextInputView: View {
    @State var textData: TextData
    @StateObject var textManager: TextManager
    @State private var textInput: String = ""
    
    @State private var textViewSize: CGSize = .zero
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            let barSize = CGSize(width: viewWidth, height: viewHeight * 0.05)
            let buttonSize = CGSize(width: barSize.height * 0.75, height: barSize.height * 0.75)
            let topPadding: CGFloat = 15
            let textViewMaxHeight: CGFloat = viewHeight - keyboardObserver.keyboardHeight - barSize.height
            VStack {
                AttributedTextView(textData: $textData,
                                   onTextChange: { textInput = $0 },
                                   onSizeChange: { _ in
                    DispatchQueue.main.async{
                        // textViewSize = $0
                    }
                })
                    .focused($isFocused)
                    .position(x: viewWidth * 0.9 / 2, y: textViewMaxHeight / 2)
                    .frame(maxWidth: viewWidth * 0.9) // TextView도 같은 값
                    // .background(.blue)
                    .padding(.top, topPadding)
                    .onChange(of: textViewSize){ newSize in
                        if newSize.height > textViewMaxHeight{
                            // 여기서 사이즈 줄이는걸로
                        }
                    }
                    .onAppear{
                        isFocused = true
                    }
                ZStack{
                    GradientRectangleView()
                    HStack{
                        Button(action: {
                            textManager.textInputCancelButtonTapped.send(textData)
                        }) {
                            Image("xmark_button")
                                .resizable()
                                .frame(width: buttonSize.width, height: buttonSize.height)
                        }
                        .padding(.leading, 10)
                        Spacer()
                        Button(action: {
                            textData.text = textInput
                            textManager.textInputConfirmButtonTapped.send(textData)
                        }) {
                            Image("xmark_button")
                                .resizable()
                                .frame(width: buttonSize.width, height: buttonSize.height)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .frame(height: barSize.height)
                .padding(.bottom, keyboardObserver.keyboardHeight)
            }
            .background(Color.black.opacity(0.3)) // 배경색 설정
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear{
            textInput = textManager.textInput()
        }
    }
}

