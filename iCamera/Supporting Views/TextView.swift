//
//  TextView.swift
//  iCamera
//
//  Created by 홍승아 on 10/23/24.
//

import SwiftUI

struct TextView: View {
    var index: Int
    var textData: TextData
    @State var textManager: TextManager
    
    @State private var textViewSize: CGSize = .zero
    @State private var backgroundViewSizeArray: [CGSize] = []
    @State private var lastTextViewHeight: CGFloat = .zero
    
    @State private var lastScale: CGFloat = 1.0
    @State private var lastAngle: Angle = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            let padding: CGFloat = 3
            
            ZStack{
                ForEach(backgroundViewSizeArray.indices, id: \.self){ index in
                    Rectangle()
                        .fill(.yellow)
                        .frame(width: backgroundViewSizeArray[index].width, height: backgroundViewSizeArray[index].height)
                        .position(x: viewWidth / 2, y: (viewHeight / 2) + (backgroundViewSizeArray[index].height * multiple(index: index)))
                }
                
                NonEditableCustomTextView(textData: textData){ newArray, newSize in
                    backgroundViewSizeArray = newArray
                    textViewSize = newSize
                }
                .frame(height: textViewSize.height)
                .position(x: viewWidth / 2, y: viewHeight / 2)
                
                if textData.isSelected{
                    Rectangle()
                        .stroke(.white, lineWidth: 1.5)
                        .frame(width: textViewSize.width + padding, height: textViewSize.height + (padding * 2))
                        .position(x: viewWidth / 2, y: viewHeight / 2)
                    
                    Image("xmark_button")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(23)
                        .position(x: viewWidth / 2 - (textViewSize.width / 2), y: (viewHeight / 2) - (textViewSize.height / 2))
                        .onTapGesture{
                            textManager.deleteTextButtonTapped.send()
                        }
                    
                    Image("xmark_button")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(23)
                        .position(x: viewWidth / 2 + (textViewSize.width / 2), y: (viewHeight / 2) + (textViewSize.height / 2))
                        .onTapGesture{
                            textManager.editTextButtonTapped.send()
                        }
                }
            }
            .scaleEffect(textManager.textArray[index].scale)
            .rotationEffect(textManager.textArray[index].angle) // 회전 효과 적용
            .gesture(
                SimultaneousGesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                textManager.textArray[index].scale = lastScale * value
                            }
                            .onEnded{ _ in
                                lastScale = textManager.textArray[index].scale
                            },
                        RotationGesture()
                            .onChanged { value in
                                textManager.textArray[index].angle = lastAngle + value
                            }
                            .onEnded{ _ in
                                lastAngle = textManager.textArray[index].angle
                            }
                        ),
                        DragGesture()
                            .onChanged{ value in
                                textManager.textArray[index].location.x += value.translation.width
                                textManager.textArray[index].location.y += value.translation.height
                            }
                            .onEnded{ _ in}
                )
            )
        }
    }
    
    private func multiple(index: Int) -> CGFloat{
        let centerIndex = backgroundViewSizeArray.count % 2 == 0 ?
        CGFloat(backgroundViewSizeArray.count - 1) / 2 : CGFloat(backgroundViewSizeArray.count / 2)
        return CGFloat(index) - centerIndex
    }
}
