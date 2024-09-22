//
//  CameraView.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import SwiftUI

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    @State var frame: CGRect

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: frame)
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

@available(iOS 16.0, *)
struct CameraView: View {
    @Binding var navigationPath: NavigationPath
    
    @StateObject private var cameraManager = CameraManager()
    @StateObject var albumManager = AlbumManager()
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    
    @State private var backZoomScale: CGFloat = 1.0
    
    @State private var navigateToTestView = false  // 상태 변수로 네비게이션 제어
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                VStack(spacing: 0){
                    
                    let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                    
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
                                NavigationLink(value: "GalleryView") {
                                    if let image = albumManager.images.first{
                                        Image(uiImage: image)
                                            .resizable()
                                            .cornerRadius(5)
                                            .frame(width: viewWidth * 0.2, height: viewWidth * 0.2)
                                            .padding(.leading, 15)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    cameraManager.switchCamera()
                                }) {
                                    Image("camera_switch_button")
                                        .resizable()
                                        .frame(width: viewWidth * 0.16, height: viewWidth * 0.16)
                                        .padding(.trailing, 15)
                                }
                            }
                            .navigationDestination(for: String.self){ value in
                                if value == "GalleryView"{
                                    GalleryView(navigationPath: $navigationPath)
                                }
                            }
                            
                            Button(action: {
                                cameraManager.takePhoto()
                            }) {
                                Image("camera_button")
                                    .resizable()
                                    .frame(width: viewWidth * 0.23, height: viewWidth * 0.23)
                            }
           
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
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            Task{
                try await albumManager.fetchRecentlyPhoto()
            }
        }
        .onChange(of: cameraManager.capturedImage) { newImage in
             if newImage != nil {
                 navigateToTestView = true  // 이미지가 설정되면 네비게이션 상태 변경
             }
         }
         .navigationDestination(isPresented: $navigateToTestView) {
             if let capturedImage = cameraManager.capturedImage {
                 TestView(navigationPath: $navigationPath, image: capturedImage)
             } else {
                 Text("No image captured")  // 예외 처리
             }
         }
    }
}
