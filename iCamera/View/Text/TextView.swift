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
    
    @State private var showRectangle = false
    
    @State private var isHidden = true
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            let padding: CGFloat = 10
            let buttonWidth: CGFloat = 20
            
            ZStack{
                    ForEach(backgroundViewSizeArray.indices, id: \.self){ index in
                        let position = backgroundArrayPosition(index: index, viewSize: geometry.size)
                        Rectangle()
                            .fill(textData.backgroundColor)
                            .frame(width: backgroundViewSizeArray[index].width, height: backgroundViewSizeArray[index].height)
                            .position(x: position.x, y: position.y) // 애니메이션 적용
                    }
                    
                    NonEditableCustomTextView(textData: .constant(textData)){ newArray, newSize in
                        // 🌀 textView textContainer(?) 업데이트 바로 안되서 width값 제대로 못받아오는 경우가 있어
                        // textInputView에서 width받아온거 저장해서 적용해줌
                        // 맨처음 추가했을때 || font크기 변경할 때
                        if textData.text == textManager.textPlaceHolder || isHidden == false {
                            backgroundViewSizeArray = newArray
                            textViewSize = newSize
                        } else {
                            backgroundViewSizeArray = textData.backgroundColorSizeArray
                            textViewSize = textData.size
                        }
                        
                        if isHidden {
                            isHidden = false
                        }
                        
                    }
                    .frame(width: textViewSize.width, height: textViewSize.height)
                    .position(x: viewWidth / 2, y: viewHeight / 2)
                    .onChange(of: textViewSize){ newSize in
                        textManager.textArray[index].size = newSize
                    }
                    //.opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
                    .animation(.easeInOut(duration: 0.1), value: isHidden)
                    
                    if textData.isSelected && showRectangle {
                        let rectangleWidth = textViewSize.width + padding
                        let rectangleHeight = textViewSize.height + (padding * 2)
                        Rectangle()
                            .stroke(.white, lineWidth: 1.5)
                            .frame(width: rectangleWidth, height: rectangleHeight)
                            .position(x: viewWidth / 2, y: viewHeight / 2)
                            // .opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
                            .animation(.easeInOut(duration: 0.1), value: isHidden)
                        
                        Image("xmark_button")
                            .resizable()
                            .frame(width: buttonWidth, height: buttonWidth)
                            .position(x: viewWidth / 2 - (rectangleWidth / 2), y: (viewHeight / 2) - (rectangleHeight / 2))
                            .onTapGesture{
                                textManager.deleteText(index: index)
                            }
                            // .opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
                            .animation(.easeInOut(duration: 0.1), value: isHidden)
                        
                        Image("edit_button")
                            .resizable()
                            .frame(width: buttonWidth, height: buttonWidth)
                            .position(x: viewWidth / 2 + (rectangleWidth / 2), y: (viewHeight / 2) + (rectangleHeight / 2))
                            .onTapGesture{
                                print("Tap")
                                textManager.editTextButtonTapped.send()
                            }
                            // .opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
                            .animation(.easeInOut(duration: 0.1), value: isHidden)
                    }
            }
            .onAppear{
                textViewSize = textData.size
                isHidden = false
                // 딜레이줘서 뷰 튀는거 방지
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    showRectangle = true
                }
            }
            .onChange(of: textData){ _ in
                isHidden = true
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
                                let translation = CGSize(width: textData.location.x + value.translation.width, height: textData.location.y + value.translation.height)
                                /*
                                // textView 드래그 범위 제한
                                let viewWidth = textViewSize.width + buttonWidth
                                let viewHeight = textViewSize.height + buttonWidth
                                let verticalPadding: CGFloat = 20
                                let textViewPositionArray = [CGPoint(x: translation.width - viewWidth / 2, y: translation.height - viewHeight / 2), CGPoint(x: translation.width + viewWidth / 2, y: translation.height + viewHeight / 2)]
                                
                                let imagePositionArray = cutImageManager.editImagePositionArray()
                               
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
                                    textManager.selectText(index: index)
                                    textManager.isFirstDrag = false
                                }
                                
                                textManager.setTextLocation(index: index, translation: translation)
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
    
    private func backgroundArrayPosition(index: Int, viewSize: CGSize) -> CGPoint{
        let size = backgroundViewSizeArray[index]
        var position: CGPoint = .zero
        switch textData.textAlignment {
        case .left:
            position.x = (viewSize.width - textViewSize.width + size.width) / 2
        case .center:
            position.x = viewSize.width / 2
        case .right:
            position.x = (viewSize.width + textViewSize.width - size.width) / 2
        default:
            break
        }
        position.y = (viewSize.height / 2) + (size.height * multiple(index: index))
        return position
    }
}
