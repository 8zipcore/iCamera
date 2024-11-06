//
//  TextManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/19/24.
//

import SwiftUI
import Combine
import UIKit

struct TextData {
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
    var scale: CGFloat
    var angle: Angle
    var isSelected: Bool
    
    static func emptyTextData() -> TextData{
        return TextData(text: "", textFont: TextFont(font: UIFont.systemFont(ofSize: 15), fontName: ""), textAlignment: .left, textColor: .black, backgroundColor: .clear, location: .zero, size: .zero, scale: .zero, angle: .zero, isSelected: false)
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
    
    @Published var textArray: [TextData] = []
    @Published var currentTextMenu: TextMenu = .font
    var textColor: [Color] = [ .black, .red, .blue, .white]
    var backgroundColor: [Color] = [.clear, .black, .white, .red, .blue]
    
    var selectedText: TextData?
    
    var fontArray: [TextFont] {
        return [
            TextFont(font: UIFont.systemFont(ofSize: 15), fontName: "title"),
            TextFont(font: UIFont.systemFont(ofSize: 10), fontName: "body"),
            TextFont(font: UIFont.systemFont(ofSize: 8), fontName: "caption")
        ]
    }
    
    private var textPlaceHolder = "텍스트를 입력해주세요."
    
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
        textArray.append(TextData(text: textPlaceHolder, textFont: TextFont(font: UIFont.systemFont(ofSize: 15), fontName: "body"), textAlignment: .center, textColor: .black, backgroundColor: .yellow, location: location, size: size, scale: 1, angle: Angle(degrees: 0), isSelected: true))
    }
    
    func addText(textData: TextData){
        textArray.indices.forEach{ textArray[$0].isSelected = false}
        textArray.append(textData)
    }
    
    func removeText(_ index: Int){
        textArray.remove(at: index)
    }
    
    func selectText(index: Int) {
        selectedText = textArray[index]
        
        var textData = textArray[index]
        textData.isSelected = true
        textData.text = ""
        textArray.remove(at: index)
        addText(textData: textData)
    }
    
    func deleteText(index: Int){
        textArray.remove(at: index)
    }
    
    func setCurrentTextMenu(_ textMenu: TextMenu){
        currentTextMenu = textMenu
    }
    
    func isSelected(_ textMenu: TextMenu) -> Bool{
        return currentTextMenu == textMenu
    }
    
    func selectedTextIndex() -> Int {
        for index in textArray.indices {
            return index
        }
        return 0
    }
    
    func setAlignment() {
        let index = selectedTextIndex()
        let currentAlignment = textArray[index].textAlignment.rawValue
        textArray[index].textAlignment = NSTextAlignment(rawValue: (currentAlignment + 1) % 3) ?? .center
    }
    
    func setTextColor(color: Color){
        let index = selectedTextIndex()
        textArray[index].textColor = color
    }
    
    func setBackgroundColor(color: Color){
        let index = selectedTextIndex()
        textArray[index].backgroundColor = color
    }
    
    func textInput() -> String{
        guard let selectedText = selectedText else { return "" }
        
        print(selectedText)
        
        if selectedText.text == textPlaceHolder{
            return ""
        }
        
        return selectedText.text
    }
}
