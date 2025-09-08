//
//  TextView.swift
//  iCamera
//
//  Created by 홍승아 on 10/23/24.
//

import SwiftUI

struct TextView: View {
    enum TextUpdateType{
        case font, input, initial
    }
    var index: Int
    var textData: TextData
    @State var textViewSize: CGSize = .zero
    @StateObject var textManager: TextManager
    @StateObject var editManager: EditManager
    var editImageViewPositionArray: [CGPoint]
    @State var backgroundViewSizeArray: [CGSize] = []
    @State var updateType: TextUpdateType = .initial
    
    @State private var lastTextViewHeight: CGFloat = .zero
    
    @State private var lastScale: CGFloat = 1.0
    @State private var lastAngle: Angle = .zero
    
    @State private var showRectangle = false
    
    @State private var isHidden = true
    
    @State private var previousTextData: TextData?
    
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
                let textViewWidthPadding: CGFloat = 100
                let textViewPositionPadding: CGFloat = updateTextViewWidthPosition(textAlignmnet: textData.textAlignment, padding: textViewWidthPadding)
                let textViewHeightPadding: CGFloat = 50
                
                    NonEditableCustomTextView(textData: .constant(textData)){ newArray, newSize in
                        // 🌀 textView textContainer(?) 업데이트 바로 안되서 width값 제대로 못받아오는 경우가 있어
                        // textInputView에서 width받아온거 저장해서 적용해줌
                        // 맨처음 추가했을때 || font크기 변경할 때
                        if updateType == .initial || updateType == .font {
                            backgroundViewSizeArray = newArray
                            textViewSize = newSize
                            // updateTextViewSize(textViewSize: textViewSize, newTextViewSize: newSize)
                        } else {
                            backgroundViewSizeArray = textData.backgroundColorSizeArray
                            textViewSize = textData.size
                        }
                        
                        if isHidden {
                            isHidden = false
                        }
                        
                    }
                    .frame(width: textViewSize.width + textViewWidthPadding, height: textViewSize.height + textViewHeightPadding, alignment: .center)
                    .position(x: viewWidth / 2 + textViewPositionPadding, y: viewHeight / 2 + textViewHeightPadding / 2)
                    .onChange(of: textViewSize){ newSize in
                        textManager.textArray[index].size = newSize
                    }
                    //                    .opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
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
                        
                        ZStack{
                            Image("xmark_button")
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                        }
                        .frame(width: buttonWidth + 10, height: buttonWidth + 10)
                        .contentShape(Rectangle())
                        .position(x: viewWidth / 2 - (rectangleWidth / 2), y: (viewHeight / 2) - (rectangleHeight / 2))
                        .onTapGesture{
                            textManager.deleteText(index: index)
                        }
                        // .opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
                        .animation(.easeInOut(duration: 0.1), value: isHidden)
                        ZStack{
                            Image("edit_button")
                                .resizable()
                                .frame(width: buttonWidth, height: buttonWidth)
                        }
                        .frame(width: buttonWidth + 10, height: buttonWidth + 10)
                        .contentShape(Rectangle())
                        .position(x: viewWidth / 2 + (rectangleWidth / 2), y: (viewHeight / 2) + (rectangleHeight / 2))
                        .onTapGesture{
                            textManager.editTextButtonTapped.send()
                        }
                        // .opacity(isHidden ? 0 : 1) // 투명도 0 = 숨김, 1 = 보임
                        .animation(.easeInOut(duration: 0.1), value: isHidden)
                    }
            }
            .onAppear{
                textViewSize = textData.size
                backgroundViewSizeArray = textData.backgroundColorSizeArray
                isHidden = false
                // 딜레이줘서 뷰 튀는거 방지
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    showRectangle = true
                }
                
                previousTextData = textData
            }
            .onReceive(NotificationCenter.default.publisher(for: .saveTextInfo)) { notification in
                textManager.textArray[index].backgroundColorSizeArray = backgroundViewSizeArray
                textManager.textArray[index].size = textViewSize
                
                textManager.completeSaveTextInfo.send()
            }
            .onChange(of: textData.text){ _ in
                updateType = .input
            }
            .onChange(of: textData.textFont.font){ _ in
                updateType = .font
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
                                // textView 드래그 범위 제한
                                let viewWidth = textViewSize.width + padding + buttonWidth
                                let viewHeight = textViewSize.height + (padding * 2) + buttonWidth
                                
                                let textViewPositionArray = [CGPoint(x: translation.width - viewWidth / 2, y: translation.height - viewHeight / 2), CGPoint(x: translation.width + viewWidth / 2, y: translation.height + viewHeight / 2)]
                               
                                if textViewPositionArray[0].x < editImageViewPositionArray[0].x {
                                    translation.width = editImageViewPositionArray[0].x + viewWidth / 2
                                } else if textViewPositionArray[1].x > editImageViewPositionArray[1].x{
                                    translation.width = editImageViewPositionArray[1].x - viewWidth / 2
                                }
                                
                                if textViewPositionArray[0].y < editImageViewPositionArray[0].y{
                                    translation.height = editImageViewPositionArray[0].y + viewHeight / 2
                                } else if textViewPositionArray[1].y > editImageViewPositionArray[1].y{
                                    translation.height = editImageViewPositionArray[1].y - viewHeight / 2
                                }
                                
                                if textManager.isFirstDrag{
                                    textManager.selectText(index: index)
                                    textManager.isFirstDrag = false
                                    editManager.selectText.send()
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
    
    private func updateTextViewSize(textViewSize: CGSize, newTextViewSize: CGSize) -> CGSize{
        if textViewSize == .zero {
            return newTextViewSize
        }
        let widthRatio = newTextViewSize.width / textViewSize.width
        let heightRatio = newTextViewSize.height / textViewSize.height
        let scale = min(widthRatio, heightRatio)

        return CGSize(
            width: textViewSize.width * scale,
            height: textViewSize.height * scale
        )
    }
    
    private func updateTextViewWidthPosition(textAlignmnet: NSTextAlignment, padding: CGFloat) -> CGFloat{
        if textAlignmnet == .left {
            return padding / 2
        } else if textAlignmnet == .right{
            return -(padding / 2)
        }
        
        return 0
    }
}
