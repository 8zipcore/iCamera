//
//  ShareSheet.swift
//  iCamera
//
//  Created by 홍승아 on 11/23/24.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
  var items: [Any]
  var viewSize: CGSize = .zero
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    
    activityViewController.modalPresentationStyle = .automatic
    
    return activityViewController
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
