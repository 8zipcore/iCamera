//
//  CameraManger.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let videoQueue = DispatchQueue(label: "videoQueue")
    
    @Published var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        
        // 카메라 세션 설정
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        session.beginConfiguration()
        
        // .high면 16:9
        session.sessionPreset = .photo
        
        // 입력 추가
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // 출력 추가
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        
        // 미리보기 레이어 설정
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspect
        
        // 세션 시작
        videoQueue.async {
            self.session.startRunning()
        }
    }
    
    // 사진 찍기
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        
        // 촬영된 사진 처리
        print("Photo captured: \(image)")
    }
}
