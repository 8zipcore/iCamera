//
//  ShareSheet.swift
//  iCamera
//
//  Created by 홍승아 on 11/23/24.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]  // 공유할 항목들 (이미지, 텍스트 등)
    var viewSize: CGSize = .zero
    
    // UIViewControllerRepresentable 프로토콜에 필요한 메서드들
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityViewController.modalPresentationStyle = .automatic
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 공유 항목이 변경되면 업데이트하는 부분
    }
    
    // Coordinator를 사용하여 SwiftUI 뷰와 UIKit 뷰 간의 상호작용을 도울 수 있습니다.
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject {
        // 필요한 경우, Coordinator에서 더 많은 작업을 처리할 수 있습니다.
    }
}
