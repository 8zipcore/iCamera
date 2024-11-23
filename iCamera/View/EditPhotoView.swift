//
//  EditPhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 9/22/24
//

import SwiftUI

@available(iOS 16.0, *)
struct EditPhotoView: View {
    @Binding var navigationPath: NavigationPath
    @State var image: UIImage = UIImage()
    @State var index: Int = -1
    
    @StateObject var albumManager: AlbumManager
    
    @StateObject var topBarViewButtonManager = TopBarViewButtonManager()
    @StateObject var menuButtonManager = MenuButtonManager()
    @StateObject var filterManager = FilterManager()
    @StateObject var stickerManager = StickerManager()
    @StateObject var cutImageManager = CutImageManager()
    @StateObject var textManager = TextManager()
    @StateObject var customSliderManager = CustomSliderManager()
    @StateObject var editManager = EditManager()
    
    @State private var filterValue: CGFloat = 0.0
    @State private var filterType: FilterType = .none
    
    @State private var isFirstDrag: Bool = true
    
    @State private var showTextInputView = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                
                let editImageViewHeight = viewHeight * 0.6
                let editImageViewPositionArray = editImageViewPositionArray(editImageViewHeight: editImageViewHeight, viewSize: geometry.size)
                
                VStack(spacing: 0){
                    TopBarView(title: "iCamera",
                               imageSize: topBarSize,
                               isLeadingButtonHidden: false,
                               isTrailingButtonHidden: false,
                               buttonManager: topBarViewButtonManager)
                    .frame(width: topBarSize.width, height: topBarSize.height)
                    .zIndex(1)
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        if buttonType == .cancel {
                            dismiss()
                        } else if buttonType == .home {
                            navigationPath.removeLast(navigationPath.count)
                        }
                    }
                    
                    /* ⭐️ imageView 시작 */
                    ZStack{
                        Color.white
                        
                        EditImageView(inputImage: $albumManager.selectedImage, value: filterValue, filterType: filterType, menuButtonManager: menuButtonManager, cutImageManager: cutImageManager)
                        /* ⭐️ StickerView 시작 */
                        ForEach(stickerManager.stickerArray.indices, id:\.self){ index in
                            let sticker = stickerManager.stickerArray[index]
                            let resizeButtonWidth: CGFloat = 10
                            
                            StickerView(index: index, sticker: sticker, stickerManager: stickerManager, editManager: editManager, editImageViewPositionArray: editImageViewPositionArray)
                                .frame(width: sticker.size.width + resizeButtonWidth, height: sticker.size.height + resizeButtonWidth)
                                .zIndex(sticker.isSelected ? 1 : 0)
                                .onTapGesture {
                                    stickerManager.selectSticker(index: index)
                                    editManager.selectSticker.send()
                                }
                                .position(sticker.location)
                                .onReceive(editManager.selectText){ _ in
                                    stickerManager.deselectAll()
                                }
                        }
                        /* ⭐️ StickerView 끝 (ForEach) */
                        /* ⭐️ TextView 시작 */
                        ForEach(textManager.textArray.indices, id: \.self){ index in
                            let data = textManager.setTextPlaceHolder(index: index)
                            TextView(index: index, textData: data, textManager: textManager, cutImageManager: cutImageManager, editManager: editManager, editImageViewPositionArray: editImageViewPositionArray)
                                .hidden(textManager.isHidden(index: index) && showTextInputView)
                                // .frame(width: data.size.width + 50, height: data.size.height)
                                .zIndex(data.isSelected ? 1 : 0)
                                .position(data.location)
                                .onTapGesture {
                                    textManager.selectText(index: index)
                                    editManager.selectText.send()
                                }
                                .onReceive(textManager.editTextButtonTapped){
                                    showTextInputView = true
                                }
                                .onReceive(editManager.selectSticker){ _ in
                                    textManager.deselectAll()
                                }
                        }
                        /* ⭐️ TextView 끝 */
                    }
                    .frame(width: viewWidth, height: editImageViewHeight)
                    /* ⭐️ imageView 끝 */
                    /* ⭐️ menuView 시작 */
                    ZStack{
                        GradientRectangleView()
                        VStack{
                            HStack(spacing: 10){
                                let menuButtons = menuButtonManager.menuButtons
                                let menuButtonViewWidth = (viewWidth * 0.6) / CGFloat(menuButtons.count)
                                let menuButtonViewHeight = menuButtonViewWidth * 10 / 17
                                
                                ForEach(menuButtons.indices, id: \.self){ index in
                                    MenuButtonView(menuButton: $menuButtonManager.menuButtons[index], buttonManager: menuButtonManager)
                                        .frame(width: menuButtonViewWidth, height: menuButtonViewHeight)
                                }
                            }
                            .padding(.top, 10)
                            .onReceive(menuButtonManager.buttonClicked){ type in
                                let selectIndex = type.rawValue
                                if menuButtonManager.menuButtons[selectIndex].isSelected { return }
                                menuButtonManager.setSelected(selectIndex)
                            }
                            /* 📌 filter */
                            if menuButtonManager.isSelected(.filter){
                                VStack{
                                    HStack(spacing: 0){
                                        ForEach(filterManager.allFilters(), id:\.self){ filter in
                                            ZStack{
                                                Image("test")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                
                                                Text(filter.title)
                                                    .foregroundStyle(Color.white)
                                            }
                                            .onTapGesture {
                                                if filterType != filter.type {
                                                    filterType = filter.type
                                                    filterValue = 0
                                                }
                                            }
                                        }
                                    }
                                    if filterType != .none{
                                        Slider(value: $filterValue, in: 0.0...1.0)
                                    }
                                }
                                .padding(.top, 10)
                                Spacer()
                            }
                            /* 📌 Sticker */
                            if menuButtonManager.isSelected(.sticker){
                                EditStickerView(stickerManager: stickerManager)
                                    .onReceive(stickerManager.addButtonClicked){ sticker in
                                        var sticker = sticker
                                        sticker.location = CGPoint(x: viewWidth / 2, y: editImageViewHeight / 2)
                                        stickerManager.addSticker(sticker)
                                        editManager.selectSticker.send()
                                    }
                            }
                            /* 📌 Cut */
                            if menuButtonManager.isSelected(.cut){
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        ForEach(cutImageManager.ratioArray.indices, id: \.self){ index in
                                            let ratio = cutImageManager.ratioArray[index]
                                            Button(action: {
                                                cutImageManager.frameRatioTapped.send(ratio)
                                            }){
                                                let text = index == 0 ? "원본" : ratio.string
                                                Text(text)
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundStyle(.black)
                                            }
                                        }
                                    }
                                    .padding([.leading, .trailing], 20)
                                }
                                .frame(height: viewHeight * 0.13)
                                CutMenuView(cutImageManager: cutImageManager)
                                Spacer()
                            }
                            /* 📌 Text */
                            if menuButtonManager.isSelected(.text){
                                EditTextView(textManager: textManager)
                                    .onReceive(textManager.textAddButtonTapped){ _ in
                                        textManager.addNewText(location: CGPoint(x: viewWidth / 2, y: editImageViewHeight / 2), size: .zero)
                                        editManager.selectText.send()
                                    }
                            }
                        }
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    /* ⭐️ menuView 끝 */
                }
                
                if showTextInputView{
                    if let textData = textManager.selectedTextData(){
                        TextInputView(textData: textData, textManager: textManager)
                            .onReceive(textManager.textInputCancelButtonTapped){ data in
                                textManager.restoreTextData(textData: data)
                                showTextInputView = false
                            }
                            .onReceive(textManager.textInputConfirmButtonTapped){ data in
                                print("tapped", data.size)
                                textManager.setTextData(textData: data)
                                showTextInputView = false
                            }
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarHidden(true)
        .onAppear{
            if index > -1{
                albumManager.fetchSelectedPhoto(for: index)
                    .sink(receiveCompletion: { completion in
                        switch completion{
                        case .finished:
                            print("finish")
                        case .failure(_):
                            print("fail")
                        }
                    }, receiveValue: { _ in })
                    .store(in: &albumManager.cancellables)
            }
            
        }
    }
    
    private func editImageViewPositionArray(editImageViewHeight: CGFloat, viewSize: CGSize) -> [CGPoint]{
        let padding: CGFloat = 7
        return [CGPoint(x: padding, y: padding), CGPoint(x: viewSize.width - padding, y: editImageViewHeight - padding)]
    }
}
