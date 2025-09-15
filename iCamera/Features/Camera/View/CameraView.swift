//
//  CameraView.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import SwiftUI

struct CameraView: View {
  enum NavigationDestination: Hashable {
    case edit
    case gallery
  }
  
  @Environment(\.dismiss) var dismiss
  
  @Binding var navigationPath: NavigationPath
  
  @StateObject private var cameraManager = CameraManager()
  @StateObject var albumManager = AlbumViewModel()
  @State private var backZoomScale: CGFloat = 1.0
  @State private var cameraButtonControlFlag = false
  
  var body: some View {
    GeometryReader { geometry in
      let cameraPreviewHeight = geometry.size.width * 4 / 3
      let cameraFrame = CGRect(
        x: 0,
        y: 0,
        width: geometry.size.width,
        height: cameraPreviewHeight
      )
      
      VStack(spacing: .zero) {
        previewSection(cameraFrame: cameraFrame)
        
        controlSection(containerSize: geometry.size)
      }
      .navigationBar(
        .camera,
        trailingButtonType: .cancel,
        onTrailingButtonTap: {
          dismiss()
        }
      )
      .navigationDestination(for: NavigationDestination.self) { destination in
        switch destination {
        case .edit:
          EditPhotoView(navigationPath: $navigationPath, albumManager: albumManager)
        case .gallery:
          GalleryView(navigationPath: $navigationPath, viewType: .camera)
        }
      }
      .onAppear{
        cameraButtonControlFlag = false
        albumManager.fetchRecentlyPhoto()
      }
      .onChange(of: cameraManager.capturedImage) { newImage in
        if let newImage = newImage, let fixedImage = newImage.fixOrientation() {
          albumManager.selectedImage = fixedImage.resized(to: CGSize(width: cameraFrame.width, height: cameraFrame.height))
          navigationPath.append(NavigationDestination.edit)
        }
      }
    }
  }
}

// MARK: - Subviews
extension CameraView {
  @ViewBuilder
  private func previewSection(cameraFrame: CGRect) -> some View {
    CameraPreview(cameraManager: cameraManager, frame: cameraFrame)
      .frame(width: cameraFrame.width, height: cameraFrame.height)
      .overlay {
        VStack {
          HStack {
            FlashButtonView(
              imageWidth: cameraFrame.width * 0.05,
              cameraManger: cameraManager
            )
            
            Spacer()
          }
          .padding(.mediumPadding)
          
          Spacer()
        }
      }
      .gesture(
        MagnificationGesture()
          .onChanged { value in
            if cameraManager.isBackCamera{
              let delta = value / self.backZoomScale
              let currentZoomFactor = self.cameraManager.currentCamera?.videoZoomFactor ?? 1.0
              let newZoomFactor = currentZoomFactor * delta
              self.cameraManager.setZoom(factor: newZoomFactor)
              self.backZoomScale = value
            }
          }
          .onEnded { _ in
            self.backZoomScale = 1.0
          }
      )
  }
  
  @ViewBuilder
  private func controlSection(containerSize: CGSize) -> some View {
    VStack {
      ZStack {
        HStack(spacing: 0) {
          if let image = albumManager.images.first{
            let imageWidth = containerSize.width * 0.17
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
              .frame(width: imageWidth, height: imageWidth)
              .clipShape(RoundedRectangle(cornerRadius: 5))
              .onTapGesture {
                navigationPath.append(NavigationDestination.gallery)
              }
          }
          
          Spacer()
          
          Button(action: {
            cameraManager.switchCamera()
          }) {
            Image("camera_switch_button")
              .resizable()
              .frame(
                width: containerSize.width * 0.16,
                height: containerSize.width * 0.16
              )
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
            .frame(
              width: containerSize.width * 0.23,
              height: containerSize.width * 0.23
            )
        }
      }
      .padding(20)
      
      Spacer()
    }
    .background(
      LinearGradient(
        gradient: Gradient(stops: [
          .init(color: .white, location: 0.2),
          .init(color: Colors.silver, location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
    )
    .frame(width: containerSize.width)
  }
}
