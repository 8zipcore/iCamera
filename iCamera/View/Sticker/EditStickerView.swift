//
//  EditStickerView.swift
//  iCamera
//
//  Created by 홍승아 on 11/16/24.
//

import SwiftUI

struct EditStickerView: View {
    
    @StateObject var stickerManager: StickerManager
    @StateObject var storedStickerManager = StoredStickerManager()
    
    @State var isEditMode = false
    @State var isExistImageInClipBoard = true
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            
            VStack{
                HStack(spacing: 10){
                    if !isExistImageInClipBoard{
                        Text("No image found in the clipboard.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.black)
                            .padding(.leading, 20)
                            .padding(.top, 5)
                    }
                    Spacer()
                    let buttonWidth: CGFloat = 25
                    Image("plus_pink_button")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                        .onTapGesture {
                            if let clipboardImage = UIPasteboard.general.image {
                                storedStickerManager.addSticker(StickerData(image: clipboardImage))
                                isExistImageInClipBoard = true
                            } else {
                                isExistImageInClipBoard = false
                            }
                        }
                    let editButtonImage = isEditMode ? "confirm_pink_button" : "edit_pink_button"
                    Image(editButtonImage)
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                        .onTapGesture {
                            isEditMode.toggle()
                        }
                }.padding(.trailing, 15)
                
                if storedStickerManager.stickerArray.count == 0 {
                    Text("Copy your special sticker\nand then press the Add button!")
                        .font(.system(size: 17, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                        .padding(.top, 20)
                    Spacer()
                } else {
                    let scrollViewWidth = viewWidth - 10
                    ScrollView(showsIndicators: false){
                        VStack{
                            let rowNumber = 5
                            let stickerArrayCount = storedStickerManager.stickerArray.count
                            var lastNumber = ((stickerArrayCount + rowNumber - 1) / rowNumber) * rowNumber
                            let rangeArray = Array(0..<lastNumber)
                            let padding: CGFloat = 5
                            ForEach(rangeArray.chunked(into: rowNumber), id: \.self) { indexArray in
                                HStack(spacing: padding){
                                    ForEach(indexArray, id: \.self) { index in
                                        let imageWidth: CGFloat = (scrollViewWidth - (padding * CGFloat(rowNumber - 1))) / CGFloat(rowNumber)
                                        ZStack{
                                            if index < stickerArrayCount{
                                                let sticker = storedStickerManager.stickerArray[index]
                                                Image(uiImage: sticker.image)
                                                    .resizable()
                                                    .frame(width: imageWidth)
                                                    .scaledToFit()
                                                    .onTapGesture {
                                                        var stickerImageSize: CGSize = .zero
                                                        let minSize = CGSize(width: 80, height: 80)
                                                        if sticker.image.size.width > sticker.image.size.height{
                                                            stickerImageSize.width = minSize.width
                                                            stickerImageSize.height = minSize.width * sticker.image.size.height / sticker.image.size.width
                                                        } else {
                                                            stickerImageSize.height = minSize.height
                                                            stickerImageSize.width = minSize.height * sticker.image.size.width / sticker.image.size.height
                                                        }
                                                        let sticker = Sticker(image: sticker.image, location: .zero, size: stickerImageSize, angle: .zero, isSelected: true)
                                                        stickerManager.addButtonClicked.send(sticker)
                                                    }
                                            } else {
                                                Rectangle()
                                                    .fill(.clear)
                                                    .frame(width: imageWidth, height: imageWidth)
                                            }
                                            if isEditMode && index < stickerArrayCount{
                                                VStack{
                                                    HStack{
                                                        Spacer()
                                                        Image("xmark_button")
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .onTapGesture {
                                                                storedStickerManager.deleteSticker(index: index)
                                                            }
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                        .frame(width: imageWidth, height: imageWidth)
                                    }
                                }
                                .padding([.leading, .trailing], 5)
                            }
                        }
                    }
                }
            }
            .onAppear{
                storedStickerManager.fetchStickers()
            }
        }
    }
}

