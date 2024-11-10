//
//  ImageInfo.swift
//  iCamera
//
//  Created by 홍승아 on 11/10/24.
//

import Foundation

struct ImageInfo{
    var frameLocation: CGPoint = .zero
    var maskRectangleViewLocation: CGPoint = .zero
    var imagePosition: CGPoint = .zero
    var lastImagePosition: CGPoint = .zero
    var zoomScale: CGFloat = 1.0
    var lastZoomScale: CGFloat = 1
    var originalImageSize: CGSize = .zero
    var imageSize: CGSize = .zero
    var previousFrameSize: CGSize = .zero
}
