//
//  EditTextView.swift
//  iCamera
//
//  Created by 홍승아 on 11/14/24.
//

import SwiftUI

struct EditTextView: View {
    @StateObject var textManager: TextManager
    
    @StateObject private var customSliderManager = CustomSliderManager()
    
    var body: some View {
        GeometryReader{ geometry in
            let viewWidth = geometry.size.width
            
            VStack(spacing: 0){
                if textManager.isSelected(.font){
                    HStack{
                        Spacer()
                        let buttonWidth: CGFloat = 25
                        Image("plus_pink_button")
                            .resizable()
                            .frame(width: buttonWidth, height: buttonWidth)
                            .padding(.trailing, 15)
                            .onTapGesture {
                                textManager.textAddButtonTapped.send()
                            }
                    }
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 10){
                            ForEach(textManager.fontArray.indices, id: \.self){ index in
                                let textFont = textManager.fontArray[index]
                                SelectedTextCell(title: textFont.fontName, font: Font(textFont.font), isSelected: textManager.isSameFont(textFont))
                                    .onTapGesture{
                                        textManager.updateFont(textFont)
                                    }
                            }
                        }
                        .padding([.leading, .trailing], 20)
                    }
                    .frame(height: 40)
                    
                    let minFontSize: CGFloat = 15
                    let maxFontSize: CGFloat = 80
                    let percentage = fontSizeToPercentage(minFontSize: minFontSize, maxFontSize: maxFontSize)
                    
                    CustomSlider(value: percentage,customSliderManager: customSliderManager, isAvailableDrag: textManager.isExistSeletedText())
                        .frame(width: viewWidth * 0.9, height: 30)
                        .padding(.top, 15)
                        .onReceive(customSliderManager.onChange){ value in
                            textManager.setFontSize((maxFontSize - minFontSize) * value + minFontSize)
                        }
                    Spacer()
                }
                
                if textManager.isSelected(.color){
                    SelectColorView(textManager: textManager)
                }
                
                Spacer()
                TextMenuView(textManager: textManager)
                    .padding(.bottom, 60)
            }
        }
    }
    
    private func fontSizeToPercentage(minFontSize: CGFloat, maxFontSize: CGFloat) -> CGFloat{
        if let selectedText = textManager.selectedText{
            return (selectedText.textFont.font.pointSize - minFontSize) / (maxFontSize - minFontSize)
        }
        return 0
    }
}
