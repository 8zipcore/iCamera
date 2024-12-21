//
//  MainView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct MainView: View {
    
    @State private var navigationPath = NavigationPath()
    @StateObject private var calendarManager = CalendarManager.shared

    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $navigationPath) {
                let viewWidth = geometry.size.width
                
                VStack(spacing: 0){
                    
                    let topBarSize = TopBarViewButtonManager().topBarViewSize(viewWidth: viewWidth)
                    
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
                        let rectangleHeight = rectangleWidth * 350 / 1032
                        let cornerRadius = rectangleHeight / 10
                        let topMargin: CGFloat = 15
                        
                        let listViewWidth =  rectangleWidth * 0.9
                        let listViewHeight = (rectangleHeight * 0.9) / 3
                        let listViewImageWidth = listViewHeight * 0.4
                        
                        let xPosition = geometry.size.width / 2
                        let menuRectangleYPosition = rectangleHeight / 2 + topMargin
                        
                        VStack(spacing: 0){
                            NavigationLink(value: "CameraView") {
                                ListView(title: "Camera", imageWidth: listViewImageWidth)
                            }
                            Spacer()
                            NavigationLink(value: "GalleryView") {
                                ListView(title: "Photos", imageWidth: listViewImageWidth)
                            }
                            Spacer()
                            NavigationLink(value: "CalendarView") {
                                ListView(title: "Calendar", imageWidth: listViewImageWidth)
                            }
                        }
                        .frame(width: listViewWidth, height: rectangleHeight * 0.7)
                        .position(x: xPosition, y: menuRectangleYPosition)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.black, lineWidth: 1)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                .frame(width: rectangleWidth, height: rectangleHeight)
                                .position(x: xPosition, y: menuRectangleYPosition)
                        )
                        .navigationDestination(for: String.self) { value in
                            switch value {
                            case "CameraView":
                                CameraView(navigationPath: $navigationPath)
                            case "GalleryView":
                                GalleryView(navigationPath: $navigationPath, viewType: .main)
                            case "CalendarView":
                                CalendarView(navigationPath: $navigationPath, calendarManager: calendarManager)
                            default:
                                TestPhotoView(navigationPath: $navigationPath, image: UIImage(named: "test") ?? UIImage(), albumManager: AlbumManager())
                            }
                        }
                        
                        let calendarRectangleHeight = rectangleWidth *  244 / 1032
                        let calendarRectangleTopPadding: CGFloat = 10
                        let calendarRectangleYPosition = topMargin + rectangleHeight + calendarRectangleTopPadding + calendarRectangleHeight / 2
                        
                        HStack(spacing: 8){
                            NavigationLink(destination: CommentsView(navigationPath: $navigationPath, calendarManager: calendarManager, viewType: .main)){
                                Text("\(calendarManager.selectedDay)")
                                    .font(.system(size: 60, weight: .medium))
                                    .foregroundStyle(Colors.titleGray)
                                VStack(spacing: 3){
                                    Text(calendarManager.getWeekdays())
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(.black)
                                    Text(calendarManager.getMonthAndYear())
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(.black)
                                }
                                Spacer()
                                Image("arrow")
                                    .resizable()
                                    .frame(width: listViewImageWidth, height: listViewImageWidth)
                            }
                        }
                        .frame(width: listViewWidth, height: calendarRectangleHeight)
                        .position(x: xPosition, y: calendarRectangleYPosition)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.black, lineWidth: 1)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                .frame(width: rectangleWidth, height: calendarRectangleHeight)
                                .position(x: xPosition, y: calendarRectangleYPosition)
                        )

                    }
                    
                }
                .background(.white)
                .edgesIgnoringSafeArea(.bottom) // 상위 뷰에서 하단 안전 영역 무시
                .onAppear{
                    // CoreDataManager.shared.deleteAllData()
                    calendarManager.fetchData()
                    calendarManager.todayDate()
                    calendarManager.dateComment = calendarManager.dateCommentToString()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
