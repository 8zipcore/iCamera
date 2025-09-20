//
//  TestPhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 9/29/24.
//

import SwiftUI

struct TestPhotoView: View {
  @Binding var navigationPath: NavigationPath
  @State var image: UIImage = UIImage()
  @State var index: Int = -1
  @State var albumManager: AlbumViewModel
  
  @State private var filterValue: CGFloat = 0.0
  
  @StateObject var menuButtonManager = EditMenuViewModel()
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    NavigationView{
      GeometryReader { geometry in
        let viewWidth = geometry.size.width
        let viewHeight = geometry.size.height
        
        VStack(spacing: 0){
//          PrimaryNavigationBar(title: "iCamera",
//                     imageSize: topBarSize,
//                     isLeadingButtonHidden: false,
//                     isTrailingButtonHidden: false,
//                     buttonManager: topBarViewButtonManager)
//          .frame(width: topBarSize.width, height: topBarSize.height)
//          .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
//            if buttonType == .cancel {
//              dismiss()
//            } else if buttonType == .home {
//              navigationPath.removeLast(navigationPath.count)
//            }
//          }
          
          ZStack{
            Color.white
              .frame(height: viewHeight * 0.7)
            
            FilteredImageView(inputImage: image, filterValue: filterValue)
              .frame(height: viewHeight * 0.7)
          }
          
          ZStack{
            Rectangle()
              .fill(
                LinearGradient(
                  gradient: Gradient(stops: [
                    .init(color: .white, location: 0.05),
                    .init(color: .silver, location: 1.0)
                  ]),
                  startPoint: .top, // 시작점
                  endPoint: .bottom // 끝점
                )
              )
            VStack{
              Text("\(filterValue)")
                .foregroundStyle(Color.black)
              Slider(value: $filterValue, in: 0.0...1.5)
            }
          }
          .ignoresSafeArea(.all, edges: .bottom)
        }
      }
    }
    .navigationBarHidden(true)
  }
}
