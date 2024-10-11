//
//  EditPhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 9/22/24.
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
    
    @State private var filterValue: CGFloat = 0.0
    @State private var filterType: FilterType = .none
    
    @State private var isFirstDrag: Bool = true
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                
                VStack(spacing: 0){
                    TopBarView(title: "iCamera",
                               imageSize: topBarSize,
                               isLeadingButtonHidden: false,
                               isTrailingButtonHidden: false,
                               buttonManager: topBarViewButtonManager)
                    .frame(width: topBarSize.width, height: topBarSize.height)
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        if buttonType == .cancel {
                            dismiss()
                        } else if buttonType == .home {
                            navigationPath.removeLast(navigationPath.count)
                        }
                    }
                    
                    let editImageViewHeight = viewHeight * 0.6
                    
                    ZStack{
                        Color.white
                        
                        EditImageView(inputImage: albumManager.selectedImage ?? UIImage(), value: filterValue, filterType: filterType, superViewSize: CGSize(width: viewWidth, height: editImageViewHeight), menuButtonManager: menuButtonManager)
                        
                        ForEach(stickerManager.stickerArray.indices, id:\.self){ index in
                            let sticker = stickerManager.stickerArray[index]
                            let resizeButtonWidth: CGFloat = 10
                            
                            StickerView(sticker: sticker, stickerManager: stickerManager)
                                .frame(width: sticker.size.width + resizeButtonWidth, height: sticker.size.height + resizeButtonWidth)
                                .onTapGesture {
                                    stickerManager.selectSticker(index: index)
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged{ value in
                                            let newIndex = stickerManager.stickerArray.count - 1
                                            if isFirstDrag{
                                                stickerManager.selectSticker(index: index)
                                                isFirstDrag = false
                                            }
                                            stickerManager.stickerArray[newIndex].location = CGPoint(x: sticker.location.x + value.translation.width, y: sticker.location.y + value.translation.height)
                                        }
                                        .onEnded{ _ in
                                            isFirstDrag = true
                                        }
                                )
                                .onReceive(stickerManager.buttonClicked) { data in
                                    if data.id != sticker.id{
                                        return
                                    }
                                    let initialSize = sticker.image.size
                                    let currentSize = sticker.size
                                    var newSize = CGSize(width: data.location.x, height: data.location.y)
                                    
                                    let location = sticker.location
                                    var newLocation: CGPoint = .zero
                                    
                                    let scale = EditStickerButton(type: data.type).position
                                    
                                    switch data.type{
                                    case .remove:
                                        stickerManager.removeSticker(index)
                                        break
                                    case .resize:
                                        let scale = max(newSize.width / currentSize.width, newSize.height / currentSize.height)
                                        newSize = CGSize(width: currentSize.width * scale, height: currentSize.height * scale)
                                        break
                                    case .trailing: fallthrough
                                    case .bottom:
                                        let widthDifferenceValue = (newSize.width - currentSize.width) * scale.x
                                        let heightDifferenceValue = (newSize.height - currentSize.height) * scale.y
                                        newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                                        newLocation = CGPoint(x: location.x + widthDifferenceValue / 2, y: location.y + heightDifferenceValue / 2)
                                    case .top: fallthrough
                                    case .leading:
                                        let widthDifferenceValue = newSize.width * scale.x
                                        let heightDifferenceValue = newSize.height * scale.y
                                        newSize = CGSize(width: currentSize.width + widthDifferenceValue, height: currentSize.height + heightDifferenceValue)
                                        newLocation = CGPoint(x: location.x - widthDifferenceValue / 2, y: location.y - heightDifferenceValue / 2)
                                    }
                                    
                                    if data.type == .remove {
                                        return
                                    }
                                    
                                    if newSize.width >= initialSize.width && newSize.height >= initialSize.height{
                                        let width = min(newSize.width, viewWidth)
                                        let height = min(newSize.height, editImageViewHeight)
                                        stickerManager.stickerArray[index].size = CGSize(width: width, height: height)
                                        
                                        if data.type != .resize{
                                            stickerManager.stickerArray[index].location = newLocation
                                        }
                                    }
                                }
                                .position(stickerManager.stickerArray[index].location)
                        }
                    }
                    .frame(height: editImageViewHeight)
                    
                    ZStack{
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .white, location: 0.05),
                                        .init(color: Colors.silver, location: 1.0)
                                    ]),
                                    startPoint: .top, // 시작점
                                    endPoint: .bottom // 끝점
                                )
                            )
                        VStack{
                            HStack(spacing: 10){
                                let menuButtons = menuButtonManager.menuButtons
                                let menuButtonViewWidth = (viewWidth * 0.7) / CGFloat(menuButtons.count)
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
                            }
                            
                            Spacer()
                        }
                        
                        if menuButtonManager.isSelected(.sticker){
                            Button("추가"){
                                if let image = UIImage(named: "star_sticker"){
                                    let sticker = Sticker(image: image, location: CGPoint(x: viewWidth / 2, y: editImageViewHeight / 2), size: image.size, isSelected: true)
                                    stickerManager.addSticker(sticker)
                                }
                            }
                        }
                        
                        if menuButtonManager.isSelected(.cut){
                            
                        }
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
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
                    }, receiveValue: {})
                    .store(in: &albumManager.cancellables)
            }
        }
    }
}
