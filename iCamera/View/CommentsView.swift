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
    @StateObject private var commentsManager = CommentsManager()
    @StateObject private var albumManager = AlbumManager()
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var imageViewHeight: CGFloat = .zero
    @State private var textInput: String = ""
    @State private var textViewSize: CGSize = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var contentHeight: CGFloat = .zero
    @State private var spacerHeight: CGFloat = .zero
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
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
                                let imageWidth = viewWidth
                                VStack(spacing: 0){
                                    ZStack{
                                        if let image = albumManager.selectedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .frame(height: imageViewHeight)
                                        } else {
                                            ZStack{
                                                Rectangle()
                                                    .fill(.white)
                                                let buttonWidth = viewWidth * 0.08
                                                Image("plus_button")
                                                    .resizable()
                                                    .frame(width: buttonWidth, height: buttonWidth)
                                            }
                                            .frame(height: imageViewHeight)
                                        }
                                        NavigationLink(value: "GalleryView"){
                                            Rectangle()
                                                .fill(.clear)
                                        }
                                    }
                                    .navigationDestination(for: String.self) { value in
                                        if value == "GalleryView" {
                                            GalleryView(navigationPath: $navigationPath,
                                                                                    viewType: .comments,
                                                                                    commentsManager: commentsManager,
                                                                                    albumManager: albumManager)
                                        }
                                    }
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
                                    let textData = TextData(text: textInput,
                                                            textFont: TextFont(font: UIFont.systemFont(ofSize: 15), fontName: "System"),
                                                            textAlignment: .left,
                                                            textColor: .black,
                                                            backgroundColor: .clear,
                                                            location: .zero,
                                                            size: .zero,
                                                            scale: 1.0,
                                                            angle: .zero,
                                                            isSelected: false)
                                    let textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                                    CustomTextView(textData: textData,
                                                   textContainerInset: textContainerInset,
                                                   textViewWidth: viewWidth * 0.88,
                                                   onTextChange: { textInput = $0 },
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
                                        if spacerHeight != .zero{
                                            spacerHeight = scrollViewHeight - (contentHeight - (textData.textFont.font.lineHeight) + textViewSize.height)
                                        }
                                        if spacerHeight < 0 {
                                            scrollProxy.scrollTo("textView", anchor: .bottom)
                                        } else {
                                            scrollProxy.scrollTo("commentsTitle", anchor: .top)
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
                                .onReceive(commentsManager.selectedImage){ (albumManager, index) in
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
                    if imageViewHeight == .zero{
                        imageViewHeight = viewWidth * 667 / 1125
                    }
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
}

@available(iOS 16.0, *)
#Preview {
    CommentsView(navigationPath: .constant(NavigationPath()), calendarManager: CalendarManager())
}
