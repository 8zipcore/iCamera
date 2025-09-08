//
//  CommentsView.swift
//  iCamera
//
//  Created by 홍승아 on 10/31/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct CommentsView: View {
    enum PreviousViewType{
        case calendar, main
    }
    
    @State var text: String = ""
    @State private var height: CGFloat = 40 // 초기 높이 설정
    
    @Binding var navigationPath: NavigationPath
    @StateObject var calendarManager: CalendarManager
    var viewType: PreviousViewType
    
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    @StateObject private var albumManager = AlbumManager()
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var imageViewHeight: CGFloat = .zero
    @State private var textViewSize: CGSize = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var spacerHeight: CGFloat = .zero
    @State private var originKeyboardHeight: CGFloat = .zero
    @State private var contentOffset: CGPoint?
    @State private var previousCursorPosition: CGPoint = .zero
    
    @State private var calendarData: CalendarData = CalendarData(date: Date(), comments: "")
    @State private var textData: TextData = .emptyTextData()
    @State private var isNavigationLinkActive = false
    
    @State private var isFocused: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                let imageWidth = viewWidth
                let topBarSize = topBarViewButtonManager.topBarViewSize(viewWidth: viewWidth)
                let barSize = CGSize(width: viewWidth, height: viewHeight * 0.05)
                let buttonSize = CGSize(width: barSize.height * 0.75, height: barSize.height * 0.75)
                let titleViewHeight = viewWidth * 110 / 1134
                
                ZStack{
                    GradientRectangleView()
                }

                VStack{
                    VStack(spacing: 0){
                        let topBarSize = TopBarViewButtonManager().topBarViewSize(viewWidth: viewWidth)
                        
                        TopBarView(title: "Comments",
                                   imageSize: topBarSize,
                                   isLeadingButtonHidden: viewType == .main,
                                   isTrailingButtonHidden: false,
                                   buttonManager: topBarViewButtonManager)
                        .frame(width: topBarSize.width, height: topBarSize.height)
                        .padding(.bottom, 3)
                        .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                            switch buttonType{
                            case .cancel:
                                dismiss()
                            case .home:
                                if viewType == .calendar{
                                    navigationPath.removeLast(navigationPath.count)
                                } else {
                                    dismiss()
                                }
                            default:
                                break
                            }
                        }
                        
                        ScrollViewWithOnScrollChanged(
                            scrollViewHeight: viewHeight - topBarSize.height,
                            contentOffset: $contentOffset,
                            content: {
                                VStack(spacing: 0){
                                    ZStack{
                                        if let imageData = calendarData.image, let image = UIImage(data: imageData) {
                                            ZStack{
                                                NavigationLink(destination: GalleryView(navigationPath: $navigationPath, viewType: .comments, calendarManager: calendarManager, albumManager: albumManager), isActive: $isNavigationLinkActive){
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .onTapGesture {
                                                            isNavigationLinkActive = true
                                                        }
                                                }
                                                
                                                VStack{
                                                    Spacer()
                                                    HStack{
                                                        Spacer()
                                                        let imageWidth: CGFloat = viewWidth * 0.16
                                                        let imageHeight: CGFloat = imageWidth * 101 / 238
                                                        ZStack{
                                                            Image("blue_button")
                                                                .resizable()
                                                                .frame(width: imageWidth, height: imageHeight)
                                                            Text("Delete")
                                                                .font(.system(size: 13, weight: .semibold))
                                                                .foregroundStyle(.white)
                                                        }
                                                    }
                                                }
                                                .padding([.bottom, .trailing], 15)
                                                .onTapGesture{
                                                    calendarData.image = nil
                                                    imageViewHeight = .zero
                                                }
                                            }
                                            
                                        } else {
                                            NavigationLink(destination: GalleryView(navigationPath: $navigationPath, viewType: .comments, calendarManager: calendarManager, albumManager: albumManager), isActive: $isNavigationLinkActive){
                                                ZStack{
                                                    let buttonWidth = viewWidth * 0.08
                                                    Rectangle()
                                                        .fill(.white)
                                                    Image("plus_button")
                                                        .resizable()
                                                        .frame(width: buttonWidth, height: buttonWidth)
                                                }
                                            }
                                        }
                                    } // Zstack 끝
                                    .frame(height: imageViewHeight == .zero ? viewWidth * 667 / 1125 : imageViewHeight)
                                    
                                    /*
                                     1. 키보드 올라가면 topbarview + 키보드view + 키보드 위에 bar View 제외한 값 구해서 스크롤뷰 높이로 설정해줌
                                     2. textView 밑에 spacer 추가해서 글자수 적을때 스크롤 시점 commentsTitle로 고정시킴
                                     3. 글자수 많으면 스크롤 시점 바닥으로 변경해서 타이핑 시점 따라가게 함
                                     */
                                    
                                    HStack{
                                        Image("pink_circle")
                                            .resizable()
                                            .frame(width: viewWidth * 0.03, height: viewWidth * 0.03)
                                        Text(calendarManager.dateComment)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.black)
                                        Spacer()
                                    }
                                    .id("commentsTitle")
                                    .frame(minHeight: titleViewHeight)
                                    .padding([.leading, .trailing], 15)
                                    
                                    let textEditorCornerRadius: CGFloat = 10
                                    let textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                                    
                                    CommentsTextView(textData: $textData,
                                                     textContainerInset: textContainerInset,
                                                     textViewWidth: viewWidth * 0.88,
                                                     onTextChange: { calendarData.comments = $0 },
                                                     onSizeChange: { newSize in
                                        if textViewSize == .zero{
                                            DispatchQueue.main.async{
                                                textViewSize = newSize
                                            }
                                        } else {
                                            if newSize != textViewSize { textViewSize = newSize }
                                        }
                                    },
                                                     onCursorChange: { caretRect, globalCaretRect in
                                        let keyboardBarYPosition = viewHeight - keyboardObserver.keyboardHeight - barSize.height
                                        let minimumBottomPadding: CGFloat = 20
                                        
                                        if textViewSize.height > scrollViewHeight && (textViewSize.height - scrollViewHeight) / 2 < caretRect.y {
                                            scrollToBottom(-1)
                                        } else if (globalCaretRect.y > keyboardBarYPosition - minimumBottomPadding) && previousCursorPosition.y != globalCaretRect.y && spacerHeight < 0{
                                            scrollToBottom(keyboardObserver.keyboardHeight - originKeyboardHeight + textData.textFont.font.pointSize)
                                        }
                                        
                                        previousCursorPosition = globalCaretRect
                                    })
                                    .animation(nil, value: scrollViewHeight)
                                    .background(Color.white)
                                    .cornerRadius(textEditorCornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: textEditorCornerRadius)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .frame(width: viewWidth * 0.88, height: textViewSize.height)
                                    .frame(minHeight: 50)
                                    .position(x: viewWidth / 2, y: (textViewSize.height / 2))
                                    .id("textView")
                                    .onChange(of: textViewSize) { _ in
                                        if isFocused {
                                            spacerHeight = scrollViewHeight - titleViewHeight - textViewSize.height
                                            
                                            if spacerHeight > 0 {
                                                scrollToTop()
                                            }
                                        }
                                    }
                                    
                                    if isFocused{
                                        Spacer(minLength: keyboardObserver.keyboardHeight + barSize.height + max(spacerHeight, 0))
                                    }
                                }
                                .onReceive(calendarManager.selectedImage){ (albumManager, asset) in
                                    self.albumManager.fetchSelectedPhoto(for: asset)
                                        .sink(receiveCompletion: { completion in
                                            switch completion{
                                            case .finished:
                                                print("finish")
                                            case .failure(_):
                                                print("fail")
                                            }
                                        }, receiveValue: { image in
                                            imageViewHeight = imageWidth * image.size.height / image.size.width
                                            calendarData.image = image.jpegData(compressionQuality: 0.7)
                                        })
                                        .store(in: &albumManager.cancellables)
                                }
                                
                            }, scrollViewDidScroll: {scrollView in })
                        .frame(width: viewWidth, height: viewHeight - topBarSize.height)
                        .onChange(of: keyboardObserver.keyboardHeight) { focused in
                            print(keyboardObserver.keyboardHeight)
                            if keyboardObserver.keyboardHeight > 0{
                                if originKeyboardHeight == .zero {
                                    originKeyboardHeight = keyboardObserver.keyboardHeight
                                }
                                scrollViewHeight = viewHeight - topBarSize.height - barSize.height - keyboardObserver.keyboardHeight
                                spacerHeight = scrollViewHeight - titleViewHeight - textViewSize.height
                                
                                
                                if spacerHeight > 0 {
                                    scrollToTop()
                                } else {
                                    let keyboardBarYPosition = viewHeight - keyboardObserver.keyboardHeight - barSize.height
                                    let minimumBottomPadding: CGFloat = 20
                                    
                                    if previousCursorPosition == .zero{
                                        scrollToBottom(-1)
                                    } else if (previousCursorPosition.y > keyboardBarYPosition - minimumBottomPadding) {
                                        scrollToBottom(keyboardObserver.keyboardHeight - originKeyboardHeight + textData.textFont.font.pointSize)
                                    }
                                }
                                
                                isFocused = true
                            }
                        }
                    } // VStack 끝
                }
                .onAppear{
                    if let index = calendarManager.calendarDataArrayIndex(){
                        print(index)
                        self.calendarData = calendarManager.calendarDataArray[index]
                        if let imageData = calendarData.image, let image = UIImage(data: imageData) {
                            imageViewHeight = imageWidth * image.size.height / image.size.width
                        }
                    } else {
                        calendarData = CalendarData(date: calendarManager.selectedDate()!, image: nil, comments: "")
                    }
                    self.textData = TextData(text: calendarData.comments,
                                             textFont: TextFont(font: UIFont.systemFont(ofSize: 15), fontName: "System"),
                                             textAlignment: .left,
                                             textColor: .black,
                                             backgroundColor: .clear,
                                             location: .zero,
                                             size: .zero,
                                             backgroundColorSizeArray: [],
                                             scale: 1.0,
                                             angle: .zero,
                                             isSelected: false)
                    isNavigationLinkActive = false
                }
                /* KeyboardView */
                if isFocused{
                    ZStack{
                        GradientRectangleView()
                        HStack{
                            Spacer()
                            Button(action: {
                                isFocused = false
                                hideKeyboard()
                            }) {
                                Image("xmark_button")
                                    .resizable()
                                    .frame(width: buttonSize.width, height: buttonSize.height)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                    .frame(width: viewWidth, height: barSize.height)
                    .position(x: viewWidth / 2, y: viewHeight - keyboardObserver.keyboardHeight - (barSize.height / 2))
                    .onAppear{
                        print("onAppear")
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .onDisappear{
                calendarManager.updateData(calendarData)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func calculateHeight() {
        let font = UIFont.systemFont(ofSize: 16)
        let width = UIScreen.main.bounds.width - 32 // 패딩 고려
        let textHeight = text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        ).height
        self.height = textHeight + 16 // 여백 추가
    }
    
    private func scrollToTop(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03){
            contentOffset = CGPoint(x: 0, y: imageViewHeight)
        }
    }
    
    private func scrollToBottom(_ yPosition: CGFloat){
        print("bottom \(yPosition)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03){
            contentOffset = CGPoint(x: -1, y: yPosition)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
