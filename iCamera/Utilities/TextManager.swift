//
//  TextManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/19/24.
//

import SwiftUI
import Combine
import UIKit

struct TextData: Equatable{
    enum Alignment: Int{
        case center, leading, trailing
    }
    var id = UUID()
    var text: String
    var textFont: TextFont
    var textAlignment: NSTextAlignment
    var textColor: Color
    var backgroundColor: Color
    var location: CGPoint
    var size: CGSize
    var backgroundColorSizeArray: [CGSize]
    var scale: CGFloat
    var angle: Angle
    var isSelected: Bool
    
    static func ==(lhs: TextData, rhs: TextData) -> Bool {
        return lhs.text == rhs.text && lhs.backgroundColorSizeArray == rhs.backgroundColorSizeArray && lhs.size == rhs.size
    }
    
    static func emptyTextData() -> TextData{
        return TextData(text: "", textFont: TextFont(font: UIFont.systemFont(ofSize: 15), fontName: ""), textAlignment: .left, textColor: .black, backgroundColor: .clear, location: .zero, size: .zero, backgroundColorSizeArray: [], scale: .zero, angle: .zero, isSelected: false)
    }
}

struct TextFont: Hashable{
    var font: UIFont
    var fontName: String
}

enum TextMenu{
    case font, alignment, color
}

class TextManager: ObservableObject{
    var fontButtonTapped = PassthroughSubject<TextFont, Never>()
    var textInputCancelButtonTapped = PassthroughSubject<TextData, Never>()
    var textInputConfirmButtonTapped = PassthroughSubject<TextData, Never>()
    var textMenuButtonTapped = PassthroughSubject<TextMenu, Never>()
    var deleteTextButtonTapped = PassthroughSubject<Void, Never>()
    var editTextButtonTapped = PassthroughSubject<Void, Never>()
    var textAddButtonTapped = PassthroughSubject<Void, Never>()
    
    @Published var textArray: [TextData] = []
    @Published var currentTextMenu: TextMenu = .font
    
    var selectedText: TextData?
    
    private var fontManager = FontManager()
    
    var fontArray: [TextFont] {
        // 첫번째는 + 버튼임
        var textFontArray: [TextFont] = [TextFont(font: UIFont.systemFont(ofSize: 20), fontName: "title")]
        FontManager.Font.allCases.forEach{ font in
            let fontName = fontManager.fontNameToString(font)
            let uiFont = fontManager.fontToUIFont(font, size: 18)
            textFontArray.append(TextFont(font:uiFont, fontName: fontName))
        }
        return textFontArray
    }
    
    let textPlaceHolder = "텍스트를 입력해주세요."
    
    var isFirstDrag = true
    
    func isHidden(index: Int) -> Bool{
        return textArray[index].isSelected
    }
    
    func selectedTextData() -> TextData?{
        return textArray.filter({ $0.isSelected }).first
    }
    
    func setTextData(textData: TextData){
        for index in textArray.indices {
            if textArray[index].id == textData.id {
                textArray[index] = textData
                selectedText = textData
                break
            }
        }
    }
    
    func restoreTextData(textData: TextData){
        if let selectedText = selectedText, selectedText.id == textData.id {
            if let index = textArray.firstIndex(where: { $0.id == selectedText.id }) {
                textArray[index].text = selectedText.text
            }
        }
    }
    
    func addNewText(location: CGPoint, size: CGSize){
        textArray.indices.forEach{ textArray[$0].isSelected = false}
        let textData = TextData(
            text: "",
            textFont: TextFont(font: fontManager.fontToUIFont(.myungjo, size: 15), fontName: fontManager.fontNameToString(.myungjo)),
            textAlignment: .center,
            textColor: .black,
            backgroundColor: .clear,
            location: location,
            size: size,
            backgroundColorSizeArray: [], 
            scale: 1,
            angle: Angle(degrees: 0),
            isSelected: true)
        textArray.append(textData)
        selectedText = textData
    }
    
    func addText(textData: TextData){
        textArray.indices.forEach{ textArray[$0].isSelected = false}
        textArray.append(textData)
    }
    
    func removeText(_ index: Int){
        textArray.remove(at: index)
    }
    
    func selectText(index: Int) {
        if textArray[index].isSelected{
            return
        }
        textArray.indices.forEach{ textArray[$0].isSelected = false }
        textArray[index].isSelected = true
        selectedText = textArray[index]
    }
    
    func deleteText(index: Int){
        if textArray[index].isSelected{
            selectedText = nil
        }
        textArray.remove(at: index)
    }
    
    func setCurrentTextMenu(_ textMenu: TextMenu){
        currentTextMenu = textMenu
    }
    
    func isSelected(_ textMenu: TextMenu) -> Bool{
        return currentTextMenu == textMenu
    }
    
    func isSelected(_ textData: TextData) -> Bool{
        return textData.id == selectedText?.id
    }

    func selectedTextIndex() -> Int? {
        for index in textArray.indices {
            if textArray[index].isSelected{
                return index
            }
        }
        return nil
    }
    
    func isSameFont(_ font: TextFont) -> Bool{
        if let selectedText = selectedText{
            return selectedText.textFont.fontName == font.fontName
        }
        return false
    }
    
    func setAlignment() {
        if let index = selectedTextIndex(){
            let currentAlignment = textArray[index].textAlignment.rawValue
            textArray[index].textAlignment = NSTextAlignment(rawValue: (currentAlignment + 1) % 3) ?? .center
        }
    }
    
    func setTextColor(color: Color){
        if let index = selectedTextIndex(){
            textArray[index].textColor = color
        }
    }
    
    func setBackgroundColor(color: Color){
        if let index = selectedTextIndex(){
            textArray[index].backgroundColor = color
        }
    }
    
    func textInput() -> String{
        guard let selectedText = selectedText else { return "" }
        return selectedText.text
    }
    
    func setTextPlaceHolder(index: Int) -> TextData{
        var textData = textArray[index]
        if textData.text.count == 0{
            textData.text = textPlaceHolder
        }
        return textData
    }
    
    func setTextLocation(index: Int, translation: CGSize){
        textArray[index].location = CGPoint(x: translation.width, y: translation.height)
    }
    
    func updateFont(_ textFont: TextFont){
        if let index = selectedTextIndex(){
            var textFont = textFont
            textFont.font = textFont.font.withSize(textArray[index].textFont.font.pointSize)
            textArray[index].textFont = textFont
            selectedText = textArray[index]
        }
    }
    
    func setFontSize(_ size: CGFloat){
        if let index = selectedTextIndex(){
            let font = textArray[index].textFont.font
            textArray[index].textFont.font = font.withSize(size)
        }
    }
    
    func setTextAlignment(){
        if let selectedIndex = selectedTextIndex(){
            let alignmentArray: [NSTextAlignment] = [.center, .left, .right]
            for index in alignmentArray.indices{
                if alignmentArray[index] == textArray[selectedIndex].textAlignment{
                    textArray[selectedIndex].textAlignment = alignmentArray[(index + 1) % alignmentArray.count]
                    break
                }
            }
        }
    }
}
