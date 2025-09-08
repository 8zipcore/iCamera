//
//  iCameraApp.swift
//  iCamera
//
//  Created by 홍승아 on 9/8/24.
//

import SwiftUI

@main
struct iCameraApp: App {
    @State private var isActive = false
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                if #available(iOS 16.0, *) {
                    if isActive {
                        MainView()
                    } else {
                        LaunchView()
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            .animation(.easeInOut(duration: 0.1), value: isActive)
            .onAppear {
                 // Launch Screen을 일정 시간 동안 보여주기
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     isActive = true
                 }
             }
        }
    }
}
