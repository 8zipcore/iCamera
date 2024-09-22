//
//  MainView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct CustomRoundedRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return roundedRect.path(in: rect)
    }
}

@available(iOS 16.0, *)
struct MainView: View {
    
    @State private var navigationPath = NavigationPath()

    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $navigationPath) {
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                VStack(spacing: 0){
                    
                    let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                    
                    TopBarView(title: "iCamera", imageSize: topBarSize, buttonManager: TopBarViewButtonManager())
                        .frame(width: topBarSize.width, height: topBarSize.height)
                    
                    ZStack{
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Colors.silver, location: 0.3),
                                .init(color: .white, location: 0.5),
                                .init(color: Colors.silver, location: 1.0)
                            ]),
                            startPoint: .top, // 시작점
                            endPoint: .bottom // 끝점
                        )
                        
                        let rectangleWidth =  viewWidth * 0.95
                        let rectangleHeight = rectangleWidth * 477 / 1032
                        let cornerRadius = rectangleHeight / 10
                        let topMargin: CGFloat = 15
                        
                        VStack(spacing: 0){
                            let listViewWidth =  rectangleWidth * 0.9
                            let listViewHeight = rectangleHeight * 0.87 / 4
                            let listViewImageWidth = listViewHeight * 0.4
                            
                            NavigationLink(value: "CameraView") {
                                ListView(title: "Camera", imageWidth: listViewImageWidth)
                                .frame(width: listViewWidth, height: listViewHeight)
                            }
                            
                            NavigationLink(value: "GalleryView") {
                                ListView(title: "Photos", imageWidth: listViewImageWidth)
                                .frame(width: listViewWidth, height: listViewHeight)
                            }
                            
                            ListView(title: "Calendar", imageWidth: listViewImageWidth)
                            .frame(width: listViewWidth, height: listViewHeight)
                            
                            ListView(title: "Setting", imageWidth: listViewImageWidth)
                            .frame(width: listViewWidth, height: listViewHeight)
                        }
                        .position(x: geometry.size.width / 2, y: rectangleHeight / 2 + topMargin)
                        .background(
                            CustomRoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.black, lineWidth: 1)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                .frame(width: rectangleWidth, height: rectangleHeight)
                                .position(x: geometry.size.width / 2, y: rectangleHeight / 2 + topMargin)
                        )
                        .navigationDestination(for: String.self) { value in
                            switch value {
                            case "CameraView":
                                CameraView(navigationPath: $navigationPath)
                            case "GalleryView":
                                GalleryView(navigationPath: $navigationPath)
                            default:
                                EmptyView()
                            }
                        }
                    }
                    
                }
                .edgesIgnoringSafeArea(.bottom) // 상위 뷰에서 하단 안전 영역 무시
            }
            .navigationBarHidden(true)
        }
    }
}
