//
//  EditPhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 9/22/24
//

import SwiftUI
import Photos

@available(iOS 16.0, *)
struct EditPhotoView: View {
    @Binding var navigationPath: NavigationPath
    @State var image: UIImage = UIImage()
    @State var asset: PHAsset?
    
    @ObservedObject var albumManager: AlbumManager
    
    @StateObject var topBarViewButtonManager = TopBarViewButtonManager()
    @StateObject var menuButtonManager = MenuButtonManager()
    @StateObject var filterManager = FilterManager()
    @StateObject var stickerManager = StickerManager()
    @StateObject var cutImageManager = CutImageManager()
    @StateObject var textManager = TextManager()
    @StateObject var customSliderManager = CustomSliderManager()
    @StateObject var editManager = EditManager()
    @StateObject var pixCropManager = PixCropManager()
    
    @State private var isFirstDrag: Bool = true
    
    @State private var showTextInputView = false
    @State private var isFontSizeChanged = false
    
    @State private var isNavigationActive = false
    @State private var renderedImage: UIImage? // Rendered image 저장
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                let topBarSize = topBarViewButtonManager.topBarViewSize(viewWidth: viewWidth)
                
                let editImageViewHeight = viewHeight * 0.6
                let editImageViewPositionArray = editImageViewPositionArray(editImageViewHeight: editImageViewHeight, viewSize: geometry.size)
                
                VStack(spacing: 0){
                    TopBarView(title: "iCamera",
                               imageSize: topBarSize,
                               isLeadingButtonHidden: false,
                               isTrailingButtonHidden: false,
                               trailingButtonType: .confirm,
                               buttonManager: topBarViewButtonManager)
                    .frame(width: topBarSize.width, height: topBarSize.height)
                    .zIndex(1)
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        if buttonType == .cancel {
                            albumManager.selectedImage = nil
                            dismiss()
                        } else if buttonType == .confirm {
                            deselectAll()
                            saveData(viewSize: geometry.size)
                        }
                    }
                    .onReceive(textManager.completeSaveTextInfo){ _ in
                        createImage(viewSize: geometry.size)
                    }
                    
                    NavigationLink(
                         isActive: $isNavigationActive,
                         destination: {
                             if let image = renderedImage{
                                 SavePhotoView(navigationPath: $navigationPath, image: image)
                             }
//                             if let image = albumManager.selectedImage {
//                                 CaptureImageView(image: image, cutImageManager: cutImageManager, textManager: textManager, stickerManager: stickerManager).frame(width: viewWidth, height: 700)
//                             }
                         },
                         label: {
                             EmptyView() // NavigationLink는 화면에 표시되지 않음
                         }
                     )
                    
                    /* ⭐️ imageView 시작 */
                    ZStack{
                        Color.white
                        
                        EditImageView(image: $albumManager.selectedImage,
                                      filterManager: filterManager,
                                      menuButtonManager: menuButtonManager,
                                      cutImageManager: cutImageManager,
                                      pixCropManager: pixCropManager)
                        .onTapGesture {
                            deselectAll()
                        }
                        
                        /* ⭐️ StickerView 시작 */
                        ForEach(stickerManager.stickerArray.indices, id:\.self){ index in
                            let sticker = stickerManager.stickerArray[index]
                            let resizeButtonWidth: CGFloat = 10
                            
                            StickerView(index: index, sticker: sticker, stickerManager: stickerManager, editManager: editManager, editImageViewPositionArray: editImageViewPositionArray)
                                .frame(width: sticker.size.width + resizeButtonWidth, height: sticker.size.height + resizeButtonWidth)
                                .zIndex(sticker.isSelected ? 1 : 0)
                                .hidden(menuButtonManager.isSelected(.cut))
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
                            TextView(index: index, textData: data, textManager: textManager, editManager: editManager, editImageViewPositionArray: editImageViewPositionArray)
                                .hidden((textManager.isHidden(index: index) && showTextInputView) || menuButtonManager.isSelected(.cut))
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
                                deselectAll()
                                let selectIndex = type.rawValue
                                if menuButtonManager.menuButtons[selectIndex].isSelected { return }
                                menuButtonManager.setSelected(selectIndex)
                            }
                            /* 📌 filter */
                            if menuButtonManager.isSelected(.filter){
                                EditFilterView(navigationPath: $navigationPath, filterManager: filterManager)
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
                                                pixCropManager.ratio(CGSize(width: ratio.widthRatio, height: ratio.heightRatio))
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
                                CutMenuView(cutImageManager: cutImageManager, pixCropManager: pixCropManager)
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
            if let asset = asset{
                albumManager.fetchSelectedPhoto(for: asset)
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
    
    private func saveData(viewSize: CGSize){
        if textManager.textArray.count > 0 {
            NotificationCenter.default.post(name: .saveTextInfo, object: nil)
        } else {
            createImage(viewSize: viewSize)
        }
    }
    
    private func createImage(viewSize: CGSize){
        if let image = renderAsImage(viewSize: viewSize){
            self.renderedImage = image
            self.isNavigationActive = true
        }
    }
        
    private func renderAsImage(viewSize: CGSize) -> UIImage?{
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("No active UIWindowScene found")
            return nil
        }
        
        guard let image = albumManager.selectedImage else { print("Image not loading"); return nil }
        
        let captureView = CaptureImageView(image: image, cutImageManager: cutImageManager, textManager: textManager, stickerManager: stickerManager, filterManager: filterManager, pixCropManager: pixCropManager).frame(width: viewSize.width, height: viewSize.height)
        let controller = UIHostingController(rootView: captureView)
        guard let view = controller.view else { return nil }

        // 캡처할 이미지 크기 설정 (이 크기와 뷰의 크기가 일치해야 합니다)
        // 뷰 크기를 imageSize에 맞게 설정
        
        view.bounds = CGRect(origin: .zero, size: window.bounds.size)
        
        let targetSize = cutImageManager.imageSize(imageSize: pixCropManager.maskSize, viewSize: viewSize)
        
        let safeAreaInsets = window.safeAreaInsets
        
        // UIGraphicsImageRenderer로 정확히 캡처할 이미지 크기 설정
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let renderImage = renderer.image { context in
            // 뷰의 중심을 맞추기 위해 좌표 이동
            let offsetX = (targetSize.width - view.bounds.width) / 2
            let offsetY = (targetSize.height - view.bounds.height - safeAreaInsets.top) / 2
            
            context.cgContext.translateBy(x: offsetX, y: offsetY)

            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        return renderImage
    }
    
    private func deselectAll(){
        textManager.deselectAll()
        stickerManager.deselectAll()
    }
}
