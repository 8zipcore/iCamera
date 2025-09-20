//
//  CameraManger.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import AVFoundation
import Photos
import SwiftUI

class CameraManager: NSObject, ObservableObject {
  private let session = AVCaptureSession()
  private let output = AVCapturePhotoOutput()
  private let videoQueue = DispatchQueue(label: "videoQueue")
  
  private var currentCameraPosition: AVCaptureDevice.Position = .back
  var isBackCamera: Bool {
    return currentCameraPosition == .back
  }
  var currentCamera: AVCaptureDevice?
  
  @Published var capturedImage: UIImage? = nil
  
  @Published var currentFlashMode: AVCaptureDevice.FlashMode = .auto
  @Published var previewLayer: AVCaptureVideoPreviewLayer?
  
  override init() {
    super.init()
    self.configure()
  }
  
  private func configure() {
    // 카메라 세션 설정
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else { return print("🌀 AVCaptureDevice error ") }
    
    self.currentCamera = camera
    
    session.beginConfiguration()
    
    session.sessionPreset = .photo
    
    if  let currentCamera = currentCamera,
        let input = try? AVCaptureDeviceInput(device: currentCamera),
        session.canAddInput(input) {
      session.addInput(input)
    }
    
    if session.canAddOutput(output) {
      session.addOutput(output)
    }
    
    session.commitConfiguration()
    
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer?.videoGravity = .resizeAspectFill
    
    videoQueue.async {
      self.session.startRunning()
    }
  }
  
  func setZoom(factor: CGFloat) {
    guard let device = currentCamera else { return }
    do {
      try device.lockForConfiguration()
      device.videoZoomFactor = max(1.0, min(factor, 5.0))
      device.unlockForConfiguration()
    } catch {
      print("Failed to set zoom factor: \(error)")
    }
  }
  
  func takePhoto() {
    var settings = AVCapturePhotoSettings()
    
    if output.availablePhotoCodecTypes.contains(.hevc) {
      settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
    } else {
      settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    }
    
    settings.flashMode = currentFlashMode
    
    output.capturePhoto(with: settings, delegate: self)
  }
  
  func switchCamera(){
    currentCameraPosition = currentCameraPosition == .back ? .front : .back
    // 카메라 세션 설정
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
      print("🌀 AVCaptureDevice error ")
      return
    }
    
    for input in session.inputs {
      session.removeInput(input)
    }
    
    if let input = try? AVCaptureDeviceInput(device: camera), session.canAddInput(input) {
      session.addInput(input)
    }
  }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let data = photo.fileDataRepresentation(),
          let image = UIImage(data: data) else { return print("🌀 error: photoOutPut is nil"); }

    DispatchQueue.main.async {
      self.capturedImage = image
    }
  }
  
  func saveImageToPhotoLibrary(image: UIImage) {
    // 사진 라이브러리 접근 권한 요청
    PHPhotoLibrary.requestAuthorization { status in
      if status == .authorized {
        // 권한이 허용된 경우
        PHPhotoLibrary.shared().performChanges({
          // 이미지 저장 요청
          let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
          creationRequest.creationDate = Date()  // 이미지 저장 날짜를 현재 시간으로 설정
        }, completionHandler: { success, error in
          if success {
            print("✅ Image successfully saved to photo library!")
          } else if let error = error {
            print("❌ Error saving image: \(error.localizedDescription)")
          }
        })
      } else {
        print("❌ Photo Library access denied.")
      }
    }
  }
}
