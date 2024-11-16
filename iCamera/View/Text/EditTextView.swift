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
            VStack{
                if textManager.isSelected(.font){
                    let minFontSize: CGFloat = 15
                    let maxFontSize: CGFloat = 80
                    let percentage = fontSizeToPercentage(minFontSize: minFontSize, maxFontSize: maxFontSize)
                    
                    CustomSlider(value: percentage,customSliderManager: customSliderManager, isAvailableDrag: textManager.isExistSeletedText())
                        .padding([.top, .leading, .trailing], 10)
                        .frame(height: 30)
                        .onReceive(customSliderManager.onChange){ value in
                            textManager.setFontSize((maxFontSize - minFontSize) * value + minFontSize)
                        }
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        
                        HStack(spacing: 10){
                            ForEach(textManager.fontArray.indices, id: \.self){ index in
                                if index == 0 {
                                    VStack{
                                        Spacer()
                                        Image("text_plus")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .onTapGesture{
                                                textManager.textAddButtonTapped.send()
                                            }
                                        Spacer()
                                    }
                                } else {
                                    let textFont = textManager.fontArray[index]
                                    SelectedTextCell(title: textFont.fontName, font: Font(textFont.font), isSelected: textManager.isSameFont(textFont))
                                        .frame(height: 30)
                                        .onTapGesture{
                                            textManager.updateFont(textFont)
                                        }
                                }
                                
                            }
                        }
                        .padding([.leading, .trailing], 20)
                    }
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
            print("selectedText",selectedText.textFont.font.pointSize)
            return (selectedText.textFont.font.pointSize - minFontSize) / (maxFontSize - minFontSize)
        }
        return 0
    }
}