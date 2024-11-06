//
//  CommentsView.swift
//  iCamera
//
//  Created by 홍승아 on 10/31/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct CommentsView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject var calendarManager: CalendarManager
    
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    @StateObject private var albumManager = AlbumManager()
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var imageViewHeight: CGFloat = .zero
    @State private var textViewSize: CGSize = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var contentHeight: CGFloat = .zero
    @State private var spacerHeight: CGFloat = .zero
    
    @State private var calendarData: CalendarData = CalendarData(date: Date(), comments: "")
    @State private var textData: TextData = .emptyTextData()
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                let imageWidth = viewWidth
                let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                let barSize = CGSize(width: viewWidth, height: viewHeight * 0.05)
                let buttonSize = CGSize(width: barSize.height * 0.75, height: barSize.height * 0.75)
                ZStack{
                    GradientRectangleView()
                }
                VStack{
                    VStack(spacing: 0){
                        TopBarView(title: "Comments",
                                   imageSize: topBarSize,
                                   isLeadingButtonHidden: false,
                                   isTrailingButtonHidden: false,
                                   buttonManager: topBarViewButtonManager)
                        .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                            switch buttonType{
                            case .cancel:
                                dismiss()
                            case .home:
                                navigationPath.removeLast(navigationPath.count)
                            default:
                                break
                            }
                        }
                        ScrollViewReader { scrollProxy in
                            ScrollView{
                                VStack(spacing: 0){
                                    ZStack{
                                        if let image = calendarData.image {
                                        // if let image = UIImage(named: "test") {
                                            ZStack{
                                                NavigationLink(destination: GalleryView(navigationPath: $navigationPath, viewType: .comments, calendarManager: calendarManager, albumManager: albumManager)){
                                                    Image(uiImage: image)
                                                        .resizable()
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
                                                    setImageViewHeight(viewWidth: viewWidth)
                                                }
                                            }
                                        } else {
                                            NavigationLink(destination: GalleryView(navigationPath: $navigationPath, viewType: .comments, calendarManager: calendarManager, albumManager: albumManager)){
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
                                    }.frame(height: imageViewHeight)
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
                                    .frame(minHeight: 50)
                                    .padding([.leading, .trailing], 15)
                                    
                                    let textEditorCornerRadius: CGFloat = 10
                                    let textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                                    CustomTextView(textData: $textData,
                                                   textContainerInset: textContainerInset,
                                                   textViewWidth: viewWidth * 0.88,
                                                   onTextChange: { calendarData.comments = $0 },
                                                   onSizeChange: { if isFocused || textViewSize == .zero {textViewSize = $0} })
                                    .focused($isFocused)
                                    .background(Color.white)
                                    .cornerRadius(textEditorCornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: textEditorCornerRadius)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .frame(width: viewWidth * 0.88, height: textViewSize.height)
                                    .padding(.bottom, 20)
                                    .id("textView")
                                    .onChange(of: textViewSize) { _ in
                                        if isFocused{
                                            if spacerHeight != .zero{
                                                spacerHeight = scrollViewHeight - (contentHeight - (textData.textFont.font.lineHeight) + textViewSize.height)
                                            }
                                            if spacerHeight < 0 {
                                                scrollProxy.scrollTo("textView", anchor: .bottom)
                                            } else {
                                                scrollProxy.scrollTo("commentsTitle", anchor: .top)
                                            }
                                        }
                                    }
                                    if isFocused{
                                        Spacer(minLength: spacerHeight > 0 ? spacerHeight : 0)
                                    }
                                }
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                contentHeight = geometry.size.height - imageViewHeight
                                        }
                                    }
                                )
                                .onReceive(calendarManager.selectedImage){ (albumManager, index) in
                                    self.albumManager.fetchSelectedPhoto(for: index)
                                        .sink(receiveCompletion: { completion in
                                            switch completion{
                                            case .finished:
                                                print("finish")
                                            case .failure(_):
                                                print("fail")
                                            }
                                        }, receiveValue: { image in
                                            imageViewHeight = imageWidth * image.size.height / image.size.width
                                            calendarData.image = image
                                        })
                                        .store(in: &albumManager.cancellables)
                                }
                            }
                            .frame(maxHeight: scrollViewHeight == .zero || !isFocused ? viewHeight - topBarSize.height : scrollViewHeight)
                            .onChange(of: keyboardObserver.keyboardHeight) { focused in
                                if keyboardObserver.keyboardHeight > 0{
                                    scrollViewHeight = viewHeight - topBarSize.height - barSize.height - keyboardObserver.keyboardHeight
                                    if spacerHeight == .zero{
                                        spacerHeight = scrollViewHeight - contentHeight
                                    }
                                    if spacerHeight > 0 {
                                        scrollProxy.scrollTo("commentsTitle", anchor: .top)
                                    }
                                }
                            }
                        }
                    } // VStack 끝
                }
                .onAppear{
                    setImageViewHeight(viewWidth: viewWidth)
                    if let index = calendarManager.calendarDataArrayIndex(){
                        self.calendarData = calendarManager.calendarDataArray[index]
                        print("같")
                        if let image = calendarData.image {
                            imageViewHeight = imageWidth * image.size.height / image.size.width
                        }
                    } else {
                        print("다")
                        calendarData = CalendarData(date: calendarManager.selectedDate()!, image: nil, comments: "")
                    }
                    self.textData = TextData(text: calendarData.comments,
                                            textFont: TextFont(font: UIFont.systemFont(ofSize: 15), fontName: "System"),
                                            textAlignment: .left,
                                            textColor: .black,
                                            backgroundColor: .clear,
                                            location: .zero,
                                            size: .zero,
                                            scale: 1.0,
                                            angle: .zero,
                                            isSelected: false)
                }
                .onDisappear{
                    calendarManager.updateData(calendarData)
                }
                /* KeyboardView */
                if isFocused{
                    ZStack{
                        GradientRectangleView()
                        HStack{
                            Spacer()
                            Button(action: {
                                isFocused = false
                            }) {
                                Image("xmark_button")
                                    .resizable()
                                    .frame(width: buttonSize.width, height: buttonSize.height)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                    .frame(height: barSize.height)
                    .position(x: viewWidth / 2, y: viewHeight - keyboardObserver.keyboardHeight - (barSize.height / 2))
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
    }
    
    private func setImageViewHeight(viewWidth: CGFloat){
        imageViewHeight = viewWidth * 667 / 1125
    }
}
@available(iOS 16.0, *)
#Preview {
    CommentsView(navigationPath: .constant(NavigationPath()), calendarManager: CalendarManager())
}
