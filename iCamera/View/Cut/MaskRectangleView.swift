//
//  MaskRectangleView.swift
//  iCamera
//
//  Created by 홍승아 on 10/5/24.
//

import SwiftUI

struct MaskRectangleView: UIViewRepresentable {
    
    var overlayColor: UIColor
    var rectangleSize: CGSize
    var maskRectangleSize: CGSize
    var maskPosition: CGPoint
    
    private let overlayLayer = CAShapeLayer()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        overlayLayer.fillColor = overlayColor.cgColor
        
        // 구멍 부분을 뚫기 위한 레이어 (원하는 크기로 구멍 설정)
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleSize.width, height: rectangleSize.height))
        let holePath = UIBezierPath(rect: CGRect(x: maskPosition.x,
                                                 y: maskPosition.y,
                                                 width: maskRectangleSize.width, 
                                                 height: maskRectangleSize.height))
        path.append(holePath)
        overlayLayer.path = path.cgPath
        overlayLayer.fillRule = .evenOdd // 가운데 구멍이 나도록 설정
        
        view.layer.addSublayer(overlayLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 기존의 overlayLayer를 제거
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        overlayLayer.fillColor = overlayColor.cgColor
        
        // 전체 레이어 덮는 검정색 경로
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleSize.width, height: rectangleSize.height))
        
        // 구멍 부분의 경로를 설정
        let holePath = UIBezierPath(rect: CGRect(x: maskPosition.x,
                                                 y: maskPosition.y,
                                                 width: maskRectangleSize.width,
                                                 height: maskRectangleSize.height))
        
        // 전체 레이어에 구멍을 추가하기 위해 append
        path.append(holePath)
        
        // 기존 overlayLayer의 경로를 업데이트
        overlayLayer.path = path.cgPath
        overlayLayer.fillRule = .evenOdd // 가운데 구멍이 나도록 설정
        
        // 다시 뷰에 추가
        uiView.layer.addSublayer(overlayLayer)
    }
}
