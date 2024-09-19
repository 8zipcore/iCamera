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
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    
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
                    
                    let bottomViewHeight = viewWidth * 361 / 1125
                    let cameraPreviewHeight = viewWidth * 4 / 3
                    let cameraFrame = CGRect(x: 0, y: 0, width: viewWidth, height: cameraPreviewHeight)
                    VStack{
                        // 카메라 미리보기
                        Spacer()
                        CameraPreview(cameraManager: cameraManager, frame: cameraFrame)
                            .frame(width: viewWidth, height: cameraFrame.height)
                        Spacer()
                        
                    }
                    .background(.white)
                    
                    ZStack{
                        HStack(spacing: 0){
                            Image("test")
                                .resizable()
                                .cornerRadius(5)
                                .frame(width: bottomViewHeight * 0.6, height: bottomViewHeight * 0.6)
                                .padding(.leading, 15)
                            
                            Spacer()
                            
                            FlashButtonView(title: "Auto", imageWidth: bottomViewHeight * 0.2)
                                .padding(.trailing, 20)
                        }
                        
                        Button(action: {
                            cameraManager.takePhoto()
                        }) {
                            Image("camera_button")
                                .resizable()
                                .frame(width: bottomViewHeight * 0.63, height: bottomViewHeight * 0.63)
                        }
                    }
                    .frame(width: viewWidth, height: bottomViewHeight)
                    .background(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0.1),
                                .init(color: Colors.silver, location: 1.0)
                            ]),
                            startPoint: .top, // 시작점
                            endPoint: .bottom // 끝점
                        )
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CameraView()
}
