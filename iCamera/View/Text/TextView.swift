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
    @StateObject var textManager: TextManager
    @StateObject var cutImageManager: CutImageManager
    
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
            let buttonWidth: CGFloat = 18
            
            ZStack{
                ForEach(backgroundViewSizeArray.indices, id: \.self){ index in
                    Rectangle()
                        // .fill(.yellow)
                        .fill(textData.backgroundColor)
                        .frame(width: backgroundViewSizeArray[index].width, height: backgroundViewSizeArray[index].height)
                        .position(x: viewWidth / 2, y: (viewHeight / 2) + (backgroundViewSizeArray[index].height * multiple(index: index)))
                }
                
                NonEditableCustomTextView(textData: textData){ newArray, newSize in
                    backgroundViewSizeArray = newArray
                    textViewSize = newSize
                }
                .frame(width: textViewSize.width, height: textViewSize.height)
                .position(x: viewWidth / 2, y: viewHeight / 2)
                .onChange(of: textViewSize){ _ in
                    // print(textViewSize)
                    // textManager.textArray[index].size = textViewSize
                }
                
                if textData.isSelected{
                    Rectangle()
                        .stroke(.white, lineWidth: 1.5)
                        .frame(width: textViewSize.width + padding, height: textViewSize.height + (padding * 2))
                        .position(x: viewWidth / 2, y: viewHeight / 2)
                    
                    Image("xmark_button")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                        .padding(30)
                        .position(x: viewWidth / 2 - (textViewSize.width / 2), y: (viewHeight / 2) - (textViewSize.height / 2))
                        .onTapGesture{
                            textManager.deleteText(index: index)
                        }
                    
                    Image("xmark_button")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                        .padding(30)
                        .position(x: viewWidth / 2 + (textViewSize.width / 2), y: (viewHeight / 2) + (textViewSize.height / 2))
                        .onTapGesture{
                            print("Tap")
                            textManager.editTextButtonTapped.send()
                        }
                }
            }
            // .scaleEffect(textData.scale)
            .rotationEffect(textData.angle) // 회전 효과 적용
            .gesture(
                SimultaneousGesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if textManager.isSelected(textData){
                                    let index = textManager.textArray.count - 1
                                    textManager.textArray[index].scale = lastScale * value
                                }
                            }
                            .onEnded{ _ in
                                let index = textManager.textArray.count - 1
                                lastScale = textManager.textArray[index].scale
                            },
                        RotationGesture()
                            .onChanged { value in
                                if textManager.isSelected(textData){
                                    let index = textManager.textArray.count - 1
                                    textManager.textArray[index].angle = lastAngle + value
                                }
                            }
                            .onEnded{ _ in
                                let index = textManager.textArray.count - 1
                                lastAngle = textManager.textArray[index].angle
                            }
                        ),
                        DragGesture()
                            .onChanged{ value in
                                var translation = CGSize(width: textData.location.x + value.translation.width, height: textData.location.y + value.translation.height)
                                let viewWidth = textViewSize.width + buttonWidth
                                let viewHeight = textViewSize.height + buttonWidth
                                let verticalPadding: CGFloat = 20
                                let textViewPositionArray = [CGPoint(x: translation.width - viewWidth / 2, y: translation.height - viewHeight / 2), CGPoint(x: translation.width + viewWidth / 2, y: translation.height + viewHeight / 2)]
                                
                                let imagePositionArray = cutImageManager.editImagePositionArray()
                                /*
                                if textViewPositionArray[0].x < imagePositionArray[0].x {
                                    translation.width = viewWidth / 2
                                } else if textViewPositionArray[1].x > imagePositionArray[1].x{
                                    translation.width = imagePositionArray[1].x - viewWidth / 2
                                }
                                
                                if textViewPositionArray[0].y < imagePositionArray[0].y{
                                    translation.height = imagePositionArray[0].y + viewHeight / 2
                                } else if textViewPositionArray[1].y > imagePositionArray[1].y{
                                    translation.height = imagePositionArray[1].y - viewHeight / 2
                                }
                                */
                                
                                if textManager.isFirstDrag{
                                    textManager.selectText(id: textData.id)
                                    textManager.isFirstDrag = false
                                }
                                
                                textManager.setTextLocation(translation)
                            }
                        .onEnded{ _ in
                            textManager.isFirstDrag = true
                        }
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
