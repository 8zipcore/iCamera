//
//  PixCropOverlayView.swift
//  Pods
//
//  Created by 홍승아 on 1/13/25.
//

import UIKit
import SnapKit

class PixCropOverlayView: UIView{
    var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    private var maskSize: CGSize = .zero
    private var maskPosition: CGPoint = .zero
    
    private let overlayLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(){
        overlayLayer.fillColor = overlayColor.cgColor

        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let holePath = UIBezierPath(rect: CGRect(x: maskPosition.x,
                                                 y: maskPosition.y,
                                                 width: maskSize.width,
                                                 height: maskSize.height))
        path.append(holePath)
        overlayLayer.path = path.cgPath
        overlayLayer.fillRule = .evenOdd
        
        self.layer.addSublayer(overlayLayer)
    }
    
    func update(){
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        initView()
    }
    
    func update(maskSize: CGSize, maskPosition: CGPoint){
        self.maskSize = maskSize
        self.maskPosition = maskPosition
        update()
    }
}

