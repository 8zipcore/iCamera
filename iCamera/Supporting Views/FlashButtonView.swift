//
//  FlashButtonView.swift
//  iCamera
//
//  Created by 홍승아 on 9/11/24.
//

import AVFoundation
import SwiftUI

struct FlashButtonView: View {
    
    @State var imageWidth: CGFloat
    @StateObject var cameraManger: CameraManager
    
    var body: some View {
        let cornerRadius: CGFloat = 20
        
        HStack(spacing: 0){
            Image("flash")
                .resizable()
                .frame(width: imageWidth, height: imageWidth)
                .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 2))
            
            Text(flashTypeToString(cameraManger.currentFlashMode))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(.trailing, 7)
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black, lineWidth: 1)
                .background(.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        )
        .onTapGesture {
            let currentRawValue = cameraManger.currentFlashMode.rawValue
            let newRawValue = currentRawValue > 1 ? 0 : currentRawValue + 1
            cameraManger.currentFlashMode = AVCaptureDevice.FlashMode(rawValue: newRawValue) ?? .auto
        }
    }
    
    private func flashTypeToString(_ type: AVCaptureDevice.FlashMode) -> String {
        switch type{
        case .auto:
            return "Auto"
        case .on:
            return "ON"
        case .off:
            return "OFF"
        @unknown default:
            return ""
        }
    }
}
