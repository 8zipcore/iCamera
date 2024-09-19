//
//  ScrollViewWithOnScrollChanged.swift
//  iCamera
//
//  Created by 홍승아 on 9/16/24.
//

import SwiftUI
import UIKit

struct ScrollViewWithOnScrollChanged<Content: View>: UIViewRepresentable {
    @ViewBuilder let content: () -> Content
    @State var scrollViewDidScroll: (_ scrollView: UIScrollView) -> Void
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()

        let hostingController = context.coordinator.hostingController
        hostingController.rootView = content()
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .white
        
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let hostingController = context.coordinator.hostingController
        hostingController.rootView = content()
        
        // scrollView의 height을 작게 설정하면
        // 내부 콘텐츠의 height > scorllView.height 이 되기 때문에 스크롤이 된다
        // ㄴ width도 작게 설정해야 되는 듯 ?!
        uiView.frame = .zero
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ScrollViewWithOnScrollChanged
        var hostingController = UIHostingController<Content?>(rootView: nil)
        
        init(_ parent: ScrollViewWithOnScrollChanged) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.scrollViewDidScroll(scrollView)
        }
    }
}
