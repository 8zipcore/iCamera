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
        if isActive {
          MainView()
        } else {
          LaunchView()
        }
      }
      .animation(.easeInOut(duration: 0.1), value: isActive)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          isActive = true
        }
      }
    }
  }
}
