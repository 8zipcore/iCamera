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
    
    @State private var filterValue: CGFloat = 0.0
    @State private var filterType: FilterType = .none
    
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
                    
                    ZStack{
                        Color.white
                        EditImageView(inputImage: albumManager.selectedImage ?? UIImage(), value: filterValue, filterType: filterType)
                    }
                    
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
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    .frame(height: viewHeight * 0.35)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            if index > -1{
                Task{
                    try await albumManager.fetchSelectedPhoto(for: index)
                }
            }
        }
    }
}
