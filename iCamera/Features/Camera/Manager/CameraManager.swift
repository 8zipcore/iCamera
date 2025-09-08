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
  
  private func configure(){
    // 카메라 세션 설정
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else { return print("🌀 AVCaptureDevice error ") }
    
    self.currentCamera = camera
    
    session.beginConfiguration()
    
    // .high면 16:9
    session.sessionPreset = .photo
    
    // 입력 추가
    if  let currentCamera = currentCamera,
        let input = try? AVCaptureDeviceInput(device: currentCamera),
        session.canAddInput(input) {
      session.addInput(input)
    }
    
    // 출력 추가
    if session.canAddOutput(output) {
      session.addOutput(output)
    }
    
    session.commitConfiguration()
    
    // 미리보기 레이어 설정
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer?.videoGravity = .resizeAspectFill
    
    // 세션 시작
    videoQueue.async {
      self.session.startRunning()
    }
  }
  
  func setZoom(factor: CGFloat) {
    guard let device = currentCamera else { return }
    do {
      try device.lockForConfiguration()
      //
      device.videoZoomFactor = max(1.0, min(factor, 5.0))
      device.unlockForConfiguration()
    } catch {
      print("Failed to set zoom factor: \(error)")
    }
  }
  
  // 사진 찍기
  func takePhoto() {
    var settings = AVCapturePhotoSettings()
    
    // photoOutput 의 codec의 hevc 가능시 photoSettings의 codec을 hevc로 설정하는 코드입니다.
    // hevc 불가능한 경우에는 jpeg codec을 사용하도록 합니다.
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
    
    // 이미지 크기와 비율 확인
    print("Image size: \(image.size.width) x \(image.size.height)") // 가로 x 세로 크기 출력
    print("Aspect ratio: \(image.size.width / image.size.height)") // 비율 확인 (4:3 -> 1.33)
    
    
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
