//
//  iCameraApp.swift
//  iCamera
//
//  Created by 홍승아 on 9/8/24.
//

import SwiftUI

@main
struct iCameraApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                MainView()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
