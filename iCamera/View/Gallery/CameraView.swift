//
//  CameraView.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import SwiftUI
import Combine

@available(iOS 16.0, *)
struct CameraView: View {
    @Binding var navigationPath: NavigationPath
    
    @StateObject private var cameraManager = CameraManager()
    @StateObject var albumManager = AlbumManager()
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    
    @State private var backZoomScale: CGFloat = 1.0
    
    @State private var isNavigating = false
    
    @State private var cameraButtonControlFlag = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                VStack(spacing: 0){
                    
                    let topBarSize = topBarViewButtonManager.topBarViewSize(viewWidth: viewWidth)
                    
                    TopBarView(title: "Camera",
                               imageSize: topBarSize,
                               isTrailingButtonHidden: false,
                               buttonManager: topBarViewButtonManager)
                    .frame(width: topBarSize.width, height: topBarSize.height)
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        if buttonType == .home {
                            dismiss()
                        }
                    }
                    
                    // let bottomViewHeight = viewWidth * 361 / 1125
                    let cameraPreviewHeight = viewWidth * 4 / 3
                    let cameraFrame = CGRect(x: 0, y: 0, width: viewWidth, height: cameraPreviewHeight)
                    
                    ZStack{
                        CameraPreview(cameraManager: cameraManager, frame: cameraFrame)
                            .frame(width: viewWidth, height: cameraFrame.height)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        // 일단 후면카메라만 줌 가능
                                        if cameraManager.isBackCamera{
                                            let delta = value / self.backZoomScale  // 핀치 제스처의 변화량
                                            let currentZoomFactor = self.cameraManager.currentCamera?.videoZoomFactor ?? 1.0
                                            let newZoomFactor = currentZoomFactor * delta
                                            self.cameraManager.setZoom(factor: newZoomFactor)  // 줌 설정
                                            self.backZoomScale = value  // 상태 업데이트
                                        }
                                    }
                                    .onEnded { _ in
                                        self.backZoomScale = 1.0  // 핀치 제스처 종료 후 배율 초기화
                                    }
                            )
                        VStack{
                            HStack{
                                FlashButtonView(imageWidth: viewWidth * 0.05, cameraManger: cameraManager)
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    
                    let bottomViewHeight = viewHeight - topBarSize.height - cameraPreviewHeight

                    VStack{
                        ZStack{
                            HStack(spacing: 0){
                                NavigationLink(destination: GalleryView(navigationPath: $navigationPath, viewType: .camera)) {
                                    if let image = albumManager.images.first{
                                        let imageWidth = viewWidth * 0.17
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: imageWidth, height: imageWidth)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .padding(.leading, 20)
                                            .onAppear{
                                                print(viewWidth * 0.17)
                                            }
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    cameraManager.switchCamera()
                                }) {
                                    Image("camera_switch_button")
                                        .resizable()
                                        .frame(width: viewWidth * 0.16, height: viewWidth * 0.16)
                                        .padding(.trailing, 20)
                                }
                            }
                            
                            Button(action: {
                                if !cameraButtonControlFlag{
                                    cameraManager.takePhoto()
                                    cameraButtonControlFlag = true
                                }
                            }) {
                                Image("camera_button")
                                    .resizable()
                                    .frame(width: viewWidth * 0.23, height: viewWidth * 0.23)
                            }
                            
                            NavigationLink(destination:EditPhotoView(navigationPath: $navigationPath, albumManager: albumManager), isActive: $isNavigating){
                                EmptyView()
                            }
                            .hidden()
           
                        }
                        .padding(.top, bottomViewHeight / 5)
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0.2),
                                .init(color: Colors.silver, location: 1.0)
                            ]),
                            startPoint: .top, // 시작점
                            endPoint: .bottom // 끝점
                        )
                    )
                    .frame(width: viewWidth)
                }
                .background(.white)
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            cameraButtonControlFlag = false

            albumManager.fetchRecentlyPhoto()
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
        .onChange(of: cameraManager.capturedImage) { newImage in
            if let newImage = newImage, let fixedImage = newImage.fixOrientation() {
                 albumManager.selectedImage = fixedImage
                 isNavigating = true
             }
         }
    }
    

}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    var frame: CGRect

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: frame)
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.frame = frame
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        guard imageOrientation != .up else {
            return self
        }
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
