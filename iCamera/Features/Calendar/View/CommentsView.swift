//
//  CommentsView.swift
//  iCamera
//
//  Created by 홍승아 on 10/31/24.
//

import SwiftUI

struct CommentsView: View {
  
  enum PreviousViewType {
    case calendar, main
  }
  
  enum NavigationDestination {
    case gallery
  }
  
  @Environment(\.dismiss) var dismiss
  
  @State var text: String = ""
  @State private var height: CGFloat = 40
  
  @Binding var navigationPath: NavigationPath
  @StateObject var calendarManager: CalendarManager
  var viewType: PreviousViewType
  
  @StateObject private var albumManager = AlbumViewModel()
  @StateObject private var keyboardObserver = KeyboardObserver()
  @State private var imageViewHeight: CGFloat = .zero
  @State private var textViewSize: CGSize = .zero
  @State private var scrollViewHeight: CGFloat = .zero
  @State private var spacerHeight: CGFloat = .zero
  @State private var originKeyboardHeight: CGFloat = .zero
  @State private var contentOffset: CGPoint?
  @State private var previousCursorPosition: CGPoint = .zero
  
  @State private var selectedImage: UIImage? = nil
  @State private var calendarData: CalendarData = CalendarData(date: Date(), comments: "")
  @State private var textData: TextData = .emptyTextData()
  
  @State private var isFocused: Bool = false
  
  private let titleViewHeight: CGFloat = 40
  private let keyboardToolBarHeight: CGFloat = 40
  
  private var scrollViewBottomPadding: CGFloat {
    keyboardToolBarHeight + keyboardObserver.keyboardHeight
  }
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack {
          imageSection()
          
          titleSection()
          
          commentsSection(containerSize: geometry.size)
          
          Spacer()
        }
        .navigationBar(
          .comments,
          onLeadingButtonTap: {
            dismiss()
          },
          trailingButtonType: .home,
          onTrailingButtonTap: {
            if viewType == .calendar{
              navigationPath.removeLast(navigationPath.count)
            } else {
              dismiss()
            }
          }
        )
      }
      .scrollIndicators(.hidden)
      .padding(.bottom, isFocused ? scrollViewBottomPadding : .zero)
      .onChange(of: keyboardObserver.keyboardHeight) { focused in
        if keyboardObserver.keyboardHeight > 0 {
          isFocused = true
        }
      }
      .background(GradientRectangleView())
      .overlay {
        keyboardToolBar(containerSize: geometry.size)
      }
      .navigationDestination(for: NavigationDestination.self) { destination in
        switch destination {
        case .gallery:
          GalleryView(
            navigationPath: $navigationPath,
            viewType: .comments,
            calendarManager: calendarManager,
            albumVM: albumManager
          )
        }
      }
      .onReceive(calendarManager.selectedImage) { albumManager, asset in
        Task {
          self.albumManager.fetchSelectedPhoto(for: asset)
        }
      }
      .onChange(of: albumManager.selectedImage) { _ in
        if let image = albumManager.selectedImage {
          selectedImage = image
          calendarData.image = image.jpegData(compressionQuality: 0.5)
        }
      }
      .onAppear {
        if let index = calendarManager.calendarDataArrayIndex() {
          self.calendarData = calendarManager.calendarDataArray[index]
          
          if let imageData = calendarData.image,
             let image = UIImage(data: imageData) {
            selectedImage = image
            imageViewHeight = geometry.size.width * image.size.height / image.size.width
          }
        } else {
          calendarData = CalendarData(date: calendarManager.selectedDate()!, image: nil, comments: "")
        }
        
        self.textData = TextData(
          text: calendarData.comments,
          textFont: TextFont(
            type: .system,
            size: 15
          ),
          textAlignment: .left,
          textColor: .black,
          backgroundColor: .clear,
          location: .zero,
          size: .zero,
          textBackgroundSizes: [],
          scale: 1.0,
          angle: .zero,
          isSelected: false
        )
      }
    }
    .ignoresSafeArea(edges: .bottom)
    .onDisappear {
      calendarManager.updateData(calendarData)
    }
  }
}

// MARK: - Subviews
extension CommentsView {
  @ViewBuilder
  private func imageSection() -> some View {
    if let image = selectedImage {
      ZStack {
        Button {
          navigationPath.append(NavigationDestination.gallery)
        } label: {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
        }
        
        VStack {
          Spacer()
          
          HStack {
            Spacer()
            
            Button {
              selectedImage = nil
              calendarData.image = nil
              imageViewHeight = .zero
            } label: {
              Image("blue_button")
                .resizable()
                .frame(width: 80, height: 30)
                .overlay {
                  Text("Delete")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                }
            }
          }
        }
        .padding([.bottom, .trailing], 15)
      }
    } else {
      VStack {
        Button {
          navigationPath.append(NavigationDestination.gallery)
        } label: {
          ZStack {
            Rectangle()
              .fill(.white)
            
            Image("plus_button")
              .resizable()
              .frame(width: 30, height: 30)
          }
        }
      }
      .frame(height: 300)
    }
  }
  
  @ViewBuilder
  private func titleSection() -> some View {
    HStack{
      Image("pink_circle")
        .resizable()
        .frame(width: 10, height: 10)
      
      Text(calendarManager.dateComment)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(.black)
      
      Spacer()
    }
    .frame(height: titleViewHeight)
    .padding([.leading, .trailing], 15)
  }
  
  @ViewBuilder
  private func commentsSection(containerSize: CGSize) -> some View {
    let textEditorCornerRadius: CGFloat = 10
    let textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    CommentsTextView(
      textData: $textData,
      textContainerInset: textContainerInset,
      textViewWidth: containerSize.width * 0.88,
      onTextChange: { calendarData.comments = $0 },
      onSizeChange: { newSize in
        Task { @MainActor in
          if textViewSize == .zero {
            textViewSize = newSize
          } else {
            if newSize != textViewSize { textViewSize = newSize }
          }
        }
      },
      onCursorChange: { caretRect, globalCaretRect in
        let keyboardBarYPosition = containerSize.height - keyboardObserver.keyboardHeight - keyboardToolBarHeight
        let minimumBottomPadding: CGFloat = 20
        
        if textViewSize.height > scrollViewHeight && (textViewSize.height - scrollViewHeight) / 2 < caretRect.y {
          scrollToBottom(-1)
        } else if (globalCaretRect.y > keyboardBarYPosition - minimumBottomPadding) && previousCursorPosition.y != globalCaretRect.y && spacerHeight < 0{
          scrollToBottom(keyboardObserver.keyboardHeight - originKeyboardHeight + textData.textFont.uiFont.pointSize)
        }
        
        previousCursorPosition = globalCaretRect
      }
    )
    .background(Color.white)
    .cornerRadius(textEditorCornerRadius)
    .overlay(
      RoundedRectangle(cornerRadius: textEditorCornerRadius)
        .stroke(Color.black, lineWidth: 1)
    )
    .frame(width: containerSize.width * 0.88, height: textViewSize.height)
    .frame(minHeight: textData.textFont.uiFont.pointSize + .smallPadding)
    .padding(.bottom, .defaultPadding)
  }
  
  @ViewBuilder
  private func keyboardToolBar(containerSize: CGSize) -> some View {
    if isFocused {
      VStack {
        Spacer()
        
        HStack {
          Spacer()
          
          Button {
            isFocused = false
            hideKeyboard()
          } label: {
            Image("confirm_button")
              .resizable()
              .frame(width: 28, height: 28)
          }
          .padding(.trailing, 10)
        }
        .frame(width: containerSize.width, height: keyboardToolBarHeight)
        .background(GradientRectangleView())
      }
      .padding(.bottom, keyboardObserver.keyboardHeight)
      .onDisappear {
        isFocused = false
      }
    }
  }
}

extension CommentsView {
  private func calculateHeight() {
    let font = UIFont.systemFont(ofSize: 16)
    let width = UIScreen.main.bounds.width - 32
    let textHeight = text.boundingRect(
      with: CGSize(width: width, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [.font: font],
      context: nil
    ).height
    
    self.height = textHeight + .defaultPadding
  }
  
  private func scrollToTop() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
      contentOffset = CGPoint(x: 0, y: imageViewHeight)
    }
  }
  
  private func scrollToBottom(_ yPosition: CGFloat) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
      contentOffset = CGPoint(x: -1, y: yPosition)
    }
  }
  
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
