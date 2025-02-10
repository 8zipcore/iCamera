//
//  PixCropView.swift
//  PixCrop
//
//  Created by 홍승아 on 1/9/25.
//

import UIKit
import SnapKit

protocol PixCropImageTransformable {
    func rotate(by degrees: Int)
    func rotateLeft()
    func rotateRight()
    func flipHorizontally()
    func flipVertically()
    func ratio(ratio: CGSize)
    func pixCropEnded(frame: CGRect) -> PixCropResultView
}

public class PixCropView: UIView {
    
    public var image = UIImage(){
        didSet{
            imageView.setImage(image)
            initPixCropImage()
            initPixCropFrame()
        }
    }
    
    public var maskSize: CGSize = .zero
    
    private var imageView = PixCropImageView(frame: .zero)
    private var frameView = PixCropFrameView()
    private var overlayView = PixCropOverlayView()
    
    private var pixCropFrame = PixCropFrameManager()
    private var pixCropImage = PixCropImageManager()
    
    private var padding: CGFloat = 25
         
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience public init(frame: CGRect, image: UIImage){
        self.init(frame: frame)
        self.image = image
        imageView.setImage(image)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initView(){
        self.addSubview(imageView)
        self.addSubview(overlayView)
        self.addSubview(frameView)
        
        overlayView.frame = CGRect(origin: .zero, size: self.frame.size)
        
        initPixCropImage()
        initPixCropFrame()
        
        updateFrameView()
        
        configureView()
    }
    
    private func configureView(){
        frameView.delegate = self
        
        self.clipsToBounds = true
        self.backgroundColor = .white
    }
    
    private func initPixCropImage(){
        let viewSize = self.frame.size
        let viewCenter = LayoutUtils.center(for: viewSize)
        
        PixCropImage.reset()
        
        PixCropImage.originalSize = LayoutUtils.scaledSizeToFit(size: image.size,
                                    viewSize: viewSizeWithoutPadding())
        PixCropImage.size = PixCropImage.originalSize
        
        PixCropImage.update(
            center: viewCenter,
            zoomScale: 1,
            updateLast: true
        )
        
        updateImageView()
    }
    
    private func initPixCropFrame(){
        let viewSize = self.frame.size
        let viewCenter = LayoutUtils.center(for: viewSize)
        
        PixCropFrame.reset()
        
        PixCropFrame.update(
            size: PixCropImage.originalSize,
            center: viewCenter,
            updateLast: true
        )
        
        PixCropFrame.minWidth = viewSize.width * 0.2
        PixCropFrame.minHeight = viewSize.height * 0.2
        
        updateFrameView()
    }
    
    private func updateFrameView(){
        self.frameView.frame.size = PixCropFrame.contentSize
        self.frameView.center = PixCropFrame.center
        
        self.overlayView.update(
            maskSize: PixCropFrame.size,
            maskPosition: LayoutUtils.topLeadingPosition(
                size: PixCropFrame.size,
                centerPosition: PixCropFrame.center
            )
        )
        
        maskSize = PixCropFrame.size
    }
    
    private func updateImageView(){
        self.imageView.transform = .identity

        self.imageView.frame.size = PixCropImage.originalSize
        self.imageView.center = PixCropImage.center
        
        self.imageView.transform = CGAffineTransform(scaleX: PixCropImage.transformScale.x * PixCropImage.zoomScale, y: PixCropImage.transformScale.y * PixCropImage.zoomScale).rotated(by: PixCropImage.degreeToRadian())
    }
    
    private func viewSizeWithoutPadding() -> CGSize{
        return CGSize(width: self.frame.width - padding, height: self.frame.height - padding)
    }
    
    private func updateView(){
        updateImageView()
        updateFrameView()
    }
}

extension PixCropView: PixCropFrameViewDragDelegate{
    func frameViewZoomming(scale: CGFloat) {
        pixCropImage.zoomImage(scale: scale)
        updateImageView()
    }
    
    func frameViewZoomEnded() {
        pixCropImage.zoomImageEnded()
        updateImageView()
    }
    
    func frameViewDragging(translation: CGPoint) {
        pixCropImage.dragImage(translation: translation, viewSize: self.frame.size)
        updateImageView()
    }
    
    func frameViewDragEnded() {
        pixCropImage.dragImageEnded()
    }
    
    func selectionBoxDragging(selectionBox: SelectionBox, location: CGPoint) {
        pixCropFrame.dragFrame(
            selectionBox: selectionBox,
            location: location,
            viewSizeWithoutPadding: viewSizeWithoutPadding(),
            viewCenter: LayoutUtils.center(for: self.frame.size)
        )
        updateFrameView()
    }
    
    func selectionBoxDragEnded(selectionBox: SelectionBox) {
        pixCropFrame.dragFrameEnded(
            selectionBox: selectionBox,
            viewSizeWithoutPadding: viewSizeWithoutPadding(),
            viewCenter: LayoutUtils.center(for: self.frame.size)
        )
        updateView()
    }
}

extension PixCropView: PixCropImageTransformable{
    public func rotate(by degrees: Int) {
        pixCropImage.rotate(by: degrees)
        updateView()
    }
    
    public func rotateLeft() {
        pixCropImage.rotate(viewSize: self.frame.size, viewSizeWithoutPadding: viewSizeWithoutPadding(), direction: .left)
        updateView()
    }
    
    public func rotateRight() {
        pixCropImage.rotate(viewSize: self.frame.size, viewSizeWithoutPadding: viewSizeWithoutPadding(), direction: .right)
        updateView()
    }
    
    public func flipHorizontally(){
        pixCropImage.flipHorizontally(
            viewCenter: LayoutUtils.center(for: self.frame.size)
        )
        updateImageView()
    }
    
    public func flipVertically() {
        pixCropImage.flipVertically(
            viewCenter: LayoutUtils.center(for: self.frame.size)
        )
        updateImageView()
    }
    
    public func ratio(ratio: CGSize) {
        pixCropFrame.ratio(ratio: ratio, viewSize: viewSizeWithoutPadding())
        pixCropImage.ratio()
        updateView()
    }
    
    public func pixCropEnded(frame: CGRect) -> PixCropResultView{
        let newFrameSize = LayoutUtils.scaledSizeToFit(size: PixCropFrame.size, viewSize: frame.size)
        let resultView = PixCropResultView(frame: frame, image: self.image)
        resultView.frame.size = newFrameSize
        maskSize = newFrameSize
        return resultView
    }
}
