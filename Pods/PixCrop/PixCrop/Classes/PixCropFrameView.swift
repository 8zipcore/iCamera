//
//  PixCropFrameView.swift
//  PixCrop
//
//  Created by 홍승아 on 1/9/25.
//

import UIKit
import SnapKit

protocol PixCropFrameViewDragDelegate {
    func frameViewDragging(translation: CGPoint)
    func frameViewDragEnded()
    func frameViewZoomming(scale: CGFloat)
    func frameViewZoomEnded()
    func selectionBoxDragging(selectionBox: SelectionBox, location: CGPoint)
    func selectionBoxDragEnded(selectionBox: SelectionBox)
}

class PixCropFrameView: UIView {
    
    private var rectangleView = UIView()
    private var selectionBoxViewArray: [PixCropSelectionBoxView] = []
    
    private let selectionBoxLineWidth = SelectionBox().lineWidth
    private let selectionBoxSize = SelectionBox().boxSize
    
    var delegate: PixCropFrameViewDragDelegate?
    
    private var initailized = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if !initailized{
            initView()
            initailized = true
        }
    }
    
    private func initView(){
        self.addSubview(rectangleView)
        selectionBoxViewArray.append(contentsOf: (0..<8).map{
            let selectionBoxView = PixCropSelectionBoxView()
            let locationType = LocationType(rawValue: $0 + 1) ?? .none
            selectionBoxView.selectionBox = SelectionBox(locationType: locationType)
            selectionBoxView.tag = $0
            selectionBoxView.clipsToBounds = true
            return selectionBoxView
        })
        
        rectangleView.snp.makeConstraints{ make in
            make.top.equalToSuperview().inset(selectionBoxLineWidth)
            make.bottom.equalToSuperview().inset(selectionBoxLineWidth)
            make.leading.equalToSuperview().inset(selectionBoxLineWidth)
            make.trailing.equalToSuperview().inset(selectionBoxLineWidth)
        }
        selectionBoxViewArray.forEach{ view in
            self.addSubview(view)
            view.snp.makeConstraints{ make in
                make.width.equalTo(selectionBoxSize.width)
                make.height.equalTo(selectionBoxSize.height)
                
                let locationType = view.selectionBox.locationType
                
                if locationType.isLeading{
                    make.leading.equalToSuperview()
                } else if locationType.isTrailing{
                    make.trailing.equalToSuperview()
                }
                
                if locationType.isTop{
                    make.top.equalToSuperview()
                } else if locationType.isBottom{
                    make.bottom.equalToSuperview()
                }
                
                if locationType.isCenter{
                    make.centerY.equalToSuperview()
                } else if locationType == .top || locationType == .bottom{
                    make.centerX.equalToSuperview()
                }
            }
        }
        configureView()
        setupGestre()
    }
    
    private func configureView(){
        rectangleView.backgroundColor = .clear
        rectangleView.layer.borderWidth = PixCropFrame.lineWidth
        rectangleView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupGestre(){
        selectionBoxViewArray.forEach{
            let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(selectionBoxViewDrag(_:)))
            $0.addGestureRecognizer(dragGestureRecognizer)
        }
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(frameViewDrag(_:)))
        self.addGestureRecognizer(dragGesture)
        
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(frameViewZoom(_:)))
        self.addGestureRecognizer(zoomGesture)
    }
}

extension PixCropFrameView{
    @objc private func selectionBoxViewDrag(_ gesture: UIPanGestureRecognizer){
        guard let view = gesture.view as? PixCropSelectionBoxView else { return }
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .changed:
            delegate?.selectionBoxDragging(selectionBox: view.selectionBox, location: location)
        case .ended:
            delegate?.selectionBoxDragEnded(selectionBox: view.selectionBox)
            break
        default:
            break
        }
    }
    
    @objc private func frameViewDrag(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self.superview)
        
        switch gesture.state {
        case .changed:
            delegate?.frameViewDragging(translation: translation)
        case .ended:
            delegate?.frameViewDragEnded()
            break
        default:
            break
        }
    }
    
    @objc private func frameViewZoom(_ gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .changed:
            delegate?.frameViewZoomming(scale: gesture.scale)
        case .ended:
            delegate?.frameViewZoomEnded()
            break
        default:
            break
        }
    }
}
