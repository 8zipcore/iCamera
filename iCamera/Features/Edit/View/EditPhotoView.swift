//
//  EditPhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 9/22/24
//

import SwiftUI
import Photos

struct EditPhotoView: View {
  
  enum NavigationDestination: Hashable {
    case savePhoto
  }
  
  @Binding var navigationPath: NavigationPath
  @State var asset: PHAsset?
  
  @StateObject var albumManager: AlbumViewModel
  
  @StateObject private var editMenuVM = EditMenuViewModel()
  @StateObject private var filterManager = FilterManager()
  @StateObject private var stickerManager = StickerManager()
  @StateObject private var cutImageManager = CutImageManager()
  @StateObject private var textManager = TextManager()
  @StateObject private var customSliderManager = CustomSliderManager()
  @StateObject private var editManager = EditManager()
  @StateObject private var pixCropManager = PixCropManager()
  
  @State private var isFirstDrag: Bool = true
  
  @State private var showTextInputView = false
  @State private var isFontSizeChanged = false
  
  @State private var isNavigationActive = false
  @State private var renderedImage: UIImage?
  
  @State private var viewWidth: CGFloat = .zero
  @State private var imageEditorSectionHeight: CGFloat = .zero
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    GeometryReader { geometry in
      let viewWidth = geometry.size.width
      let viewHeight = geometry.size.height
    
      let imageViewPositions = imageViewPositions(
        editImageViewHeight: imageEditorSectionHeight,
        viewSize: geometry.size
      )
      
      ZStack {
        VStack(spacing: .zero) {
          imageEditorSection(imageViewPositions)
            .frame(width: viewWidth, height: imageEditorSectionHeight)
          
          menuSection()
        }
        .onReceive(textManager.completeSaveTextInfo){ _ in
          createImage(viewSize: geometry.size)
        }
        
        textInputView()
      }
      .navigationBar(
        .edit,
        onLeadingButtonTap: {
          albumManager.selectedImage = nil
          dismiss()
        },
        trailingButtonType: .confirm,
        onTrailingButtonTap: {
          deselectAll()
          saveData(viewSize: geometry.size)
        }
      )
      .navigationDestination(for: NavigationDestination.self) { destination in
        switch destination {
        case .savePhoto:
          if let image = renderedImage {
            SavePhotoView(navigationPath: $navigationPath, image: image)
          }
        }
      }
      .onAppear {
        self.viewWidth = viewWidth
        self.imageEditorSectionHeight = viewHeight * 0.5
      }
    }
    .ignoresSafeArea(.keyboard)
    .onAppear {
      if let asset = asset {
        albumManager.fetchSelectedPhoto(for: asset)
      }
    }
  }
}

// MARK: - Subviews
extension EditPhotoView {
  @ViewBuilder
  private func textInputView() -> some View {
    if showTextInputView {
      if let textData = textManager.selectedTextData() {
        TextInputView(textData: textData, textManager: textManager)
          .onReceive(textManager.textInputCancelButtonTapped) { data in
            textManager.restoreTextData(textData: data)
            showTextInputView = false
          }
          .onReceive(textManager.textInputConfirmButtonTapped) { data in
            textManager.setTextData(textData: data)
            showTextInputView = false
          }
      }
    }
  }
  
  // MARK: - ImageEditorSection
  private func imageEditorSection(_ imageViewPositions: [CGPoint]) -> some View {
    ZStack {
      EditImageView(
        image: $albumManager.selectedImage,
        isCutSelected: editMenuVM.isSelected(.cut),
        filterManager: filterManager,
        cutImageManager: cutImageManager,
        pixCropManager: pixCropManager
      )
      .onTapGesture {
        deselectAll()
      }
      
      stickerSection(imageViewPositions)
      
      textSection(imageViewPositions)
    }
  }
  
  @ViewBuilder
  private func stickerSection(_ imageViewPositions: [CGPoint]) -> some View {
    ForEach(stickerManager.stickerArray.indices, id:\.self){ index in
      let sticker = stickerManager.stickerArray[index]
      let resizeButtonWidth: CGFloat = 10
      
      StickerView(
        index: index,
        sticker: sticker,
        stickerManager: stickerManager,
        editManager: editManager,
        imageViewPositions: imageViewPositions
      )
      .frame(
        width: sticker.size.width + resizeButtonWidth,
        height: sticker.size.height + resizeButtonWidth
      )
      .zIndex(sticker.isSelected ? 1 : 0)
      .hidden(editMenuVM.isSelected(.cut))
      .onTapGesture {
        stickerManager.selectSticker(index: index)
        editManager.selectSticker.send()
      }
      .position(sticker.location)
      .onReceive(editManager.selectText) { _ in
        stickerManager.deselectAll()
      }
    }
  }
  
  @ViewBuilder
  private func textSection(_ imageViewPositions: [CGPoint]) -> some View {
    ForEach(textManager.textArray.indices, id: \.self) { index in
      let data = textManager.setTextPlaceHolder(index: index)
      TextView(
        index: index,
        textData: data,
        textManager: textManager,
        editManager: editManager,
        editImageViewPositionArray: imageViewPositions,
        containerSize: CGSize(width: viewWidth, height: imageEditorSectionHeight)
      )
      .zIndex(data.isSelected ? 1 : 0)
      .position(data.location)
      .onTapGesture {
        textManager.selectText(index: index)
        editManager.selectText.send()
      }
      .onReceive(textManager.editTextButtonTapped) {
        showTextInputView = true
      }
      .onReceive(editManager.selectSticker) { _ in
        textManager.deselectAll()
      }
    }
  }
  
  // MARK: - MenuSection
  private func menuSection() -> some View {
    VStack {
      menuButtonSection()
      
      filterMenuSection()
      
      stickerMenuSection()
      
      cutMenuSection()
      
      textMenuSection()
      
      Spacer()
    }
    .background(GradientRectangleView())
  }
  
  @ViewBuilder
  private func menuButtonSection() -> some View {
    HStack(spacing: 10) {
      let menuButtons = editMenuVM.menuButtons
      let menuButtonViewWidth = (viewWidth * 0.6) / CGFloat(menuButtons.count)
      let menuButtonViewHeight = menuButtonViewWidth * 10 / 17
      
      ForEach(menuButtons.indices, id: \.self){ index in
        MenuButtonView(
          menuButton: $editMenuVM.menuButtons[index],
          editMenuVM: editMenuVM
        )
        .frame(width: menuButtonViewWidth, height: menuButtonViewHeight)
      }
    }
    .padding(.top, 10)
    .onReceive(editMenuVM.buttonClicked) { type in
      deselectAll()
      
      let selectIndex = type.rawValue
      if editMenuVM.menuButtons[selectIndex].isSelected { return }
      editMenuVM.setSelected(selectIndex)
    }
  }
  
  @ViewBuilder
  private func filterMenuSection() -> some View {
    if editMenuVM.isSelected(.filter) {
      EditFilterView(
        navigationPath: $navigationPath,
        filterManager: filterManager
      )
    }
  }
  
  @ViewBuilder
  private func stickerMenuSection() -> some View {
    if editMenuVM.isSelected(.sticker){
      EditStickerView(stickerManager: stickerManager)
        .onReceive(stickerManager.addButtonClicked) { sticker in
          var sticker = sticker
          sticker.location = CGPoint(
            x: viewWidth / 2,
            y: imageEditorSectionHeight / 2
          )
          stickerManager.addSticker(sticker)
          editManager.selectSticker.send()
        }
    }
  }
  
  @ViewBuilder
  private func cutMenuSection() -> some View {
    if editMenuVM.isSelected(.cut){
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 20) {
          ForEach(cutImageManager.ratioArray.indices, id: \.self) { index in
            let ratio = cutImageManager.ratioArray[index]
            Button {
                pixCropManager.ratio(
                  CGSize(
                    width: ratio.widthRatio,
                    height: ratio.heightRatio
                  )
                )
            } label: {
              let text = index == 0 ? "원본" : ratio.string
              Text(text)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.black)
            }
          }
        }
        .padding(.horizontal, 20)
      }
      .frame(height: 50)
      
      CutMenuView(cutImageManager: cutImageManager, pixCropManager: pixCropManager)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  private func textMenuSection() -> some View {
    if editMenuVM.isSelected(.text) {
      EditTextView(textManager: textManager)
        .onReceive(textManager.textAddButtonTapped) { _ in
          textManager.addNewText(
            location: CGPoint(
              x: viewWidth / 2,
              y: imageEditorSectionHeight / 2
            ),
            size: .zero
          )
          editManager.selectText.send()
        }
    }
  }
}

extension EditPhotoView {
  private func imageViewPositions(editImageViewHeight: CGFloat, viewSize: CGSize) -> [CGPoint] {
    let padding: CGFloat = 7
    return [CGPoint(x: padding, y: padding), CGPoint(x: viewSize.width - padding, y: editImageViewHeight - padding)]
  }
  
  private func saveData(viewSize: CGSize) {
    if textManager.textArray.count > 0 {
      NotificationCenter.default.post(name: .saveTextInfo, object: nil)
    } else {
      createImage(viewSize: viewSize)
    }
  }
  
  private func createImage(viewSize: CGSize) {
    if let image = renderAsImage(viewSize: viewSize) {
      self.renderedImage = image
      navigationPath.append(NavigationDestination.savePhoto)
    }
  }
  
  private func renderAsImage(viewSize: CGSize) -> UIImage? {
    guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
          let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
      print("No active UIWindowScene found")
      return nil
    }
    
    guard let image = albumManager.selectedImage else {
      print("Image not loading")
      return nil
    }
    
    let captureView = CaptureImageView(
      image: image,
      cutImageManager: cutImageManager,
      textManager: textManager,
      stickerManager: stickerManager,
      filterManager: filterManager,
      pixCropManager: pixCropManager
    )
      .frame(width: viewSize.width, height: viewSize.height)
    
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
  
  private func deselectAll() {
    textManager.deselectAll()
    stickerManager.deselectAll()
  }
  
  private func isTextViewHidden(_ index: Int) -> Bool {
    (textManager.isHidden(index: index) && showTextInputView) || editMenuVM.isSelected(.cut)
  }
}
