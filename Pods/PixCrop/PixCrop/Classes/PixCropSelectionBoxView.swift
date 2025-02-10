//
//  PixCropSelectionBoxView.swift
//  PixCrop
//
//  Created by 홍승아 on 1/9/25.
//

import UIKit

class PixCropSelectionBoxView: UIView {
    var selectionBox = SelectionBox(){
        didSet{
            initView()
        }
    }
    
    private let overlayLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(){
        overlayLayer.removeFromSuperlayer()
        
        overlayLayer.fillColor = UIColor.black.cgColor
        
        let selectionBoxSize = CGSize(width: 50, height: 50)
        let selectionBoxPosition = CGPoint(
            x: -(selectionBoxSize.width - selectionBox.boxSize.width) / 2,
            y: -(selectionBoxSize.height - selectionBox.boxSize.height) / 2
        )
        
        let path = UIBezierPath(
            rect: CGRect(origin: selectionBoxPosition, size: selectionBoxSize))
        let holePath = UIBezierPath(rect: selectionBox.maskRect())
        
        path.append(holePath)
        
        overlayLayer.path = path.cgPath
        overlayLayer.fillRule = .evenOdd
        
        self.layer.addSublayer(overlayLayer)
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
    }
}
