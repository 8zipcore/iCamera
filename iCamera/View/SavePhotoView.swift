//
//  SavePhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 11/23/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct SavePhotoView: View {
    @Binding var navigationPath: NavigationPath
    @State var image: UIImage
    @StateObject var topBarViewButtonManager = TopBarViewButtonManager()
    @StateObject var albumManager = AlbumManager()
    
    @State private var showShareSheet = false
    @State private var isSaved = false
    
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
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        dismiss()
                    }
                    ZStack{
                        GradientRectangleView()
                        VStack(spacing: 0){
                            VStack{
                                Spacer()
                                Text("Upload Your Lucky Photo! ࣪ꕤ˚₊⊹")
                                    .font(.system(size: 19, weight: .medium))
                                    .foregroundStyle(.black)
                            }
                            .frame(height: viewHeight * 0.1)
                            
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: viewWidth * 0.9, maxHeight: viewHeight * 0.45)
                                .padding([.top, .bottom], 40)
                            
                            Button(action:{
                                albumManager.saveImageToPhotos(image: image, completion: {
                                    isSaved = true
                                })
                            }){
                                let imageWidth: CGFloat = viewWidth * 0.19
                                let imageHeight: CGFloat = imageWidth * 54 / 119
                                ZStack{
                                    Image(isSaved ? "gray_button" : "blue_button")
                                        .resizable()
                                        .frame(width: imageWidth, height: imageHeight)
                                    Text(isSaved ? "Complete" : "Save")
                                        .font(.system(size: isSaved ? 12 : 14, weight: .semibold))
                                        .foregroundStyle(isSaved ? Colors.titleGray : .white)
                                }
                            }
                            
                            Button(action:{
                                showShareSheet.toggle()
                            }){
                                let imageWidth: CGFloat = viewWidth * 0.19
                                let imageHeight: CGFloat = imageWidth * 54 / 119
                                ZStack{
                                    Image("blue_button")
                                        .resizable()
                                        .frame(width: imageWidth, height: imageHeight)
                                    Text("Share")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.top, 30)
                            .sheet(isPresented: $showShareSheet, content: {
                                ShareSheet(items: [image], viewSize: CGSize(width: viewWidth, height: viewHeight * 0.5))
                            })
                            Spacer()
                        }
                    }
                }
                .background(.white)
            }
        }
        .navigationBarHidden(true)
    }
}
@available(iOS 16.0, *)
#Preview {
    SavePhotoView(navigationPath: .constant(NavigationPath()), image: UIImage(named: "test")!)
}
