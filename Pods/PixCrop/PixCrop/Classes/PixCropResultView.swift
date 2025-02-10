//
//  PixCropResultView.swift
//  Pods
//
//  Created by 홍승아 on 2/5/25.
//

import Foundation

public class PixCropResultView: UIView{
    public var imageView = PixCropImageView(frame: .zero)
    private var overlayView = PixCropOverlayView()
    
    public var overlayColor: UIColor = .white{
        didSet{
            self.overlayView.overlayColor = overlayColor
        }
    }
    
    public var image: UIImage = UIImage(){
        didSet{
            imageView.setImage(image)
        }
    }
    
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
        
        self.overlayView.frame.size = CGSize(
            width: self.frame.width,
            height: self.frame.height + 5
        )
        
        self.overlayView.overlayColor = overlayColor
        
        self.backgroundColor = .white
        self.clipsToBounds = true
        
        self.imageView.frame.size = PixCropImage.originalSize
        self.imageView.center = PixCropImage.center

        configureView()
    }
    
    private func configureView(){
        let viewCenter = self.center
        let previousFrameSize = PixCropFrame.size
        let newFrameSize = LayoutUtils.scaledSizeToFit(
            size: PixCropFrame.size,
            viewSize: self.frame.size
        )
        /* Image ZoomScale 변환 */
        var newZoomScale = PixCropImage.zoomScale
        newZoomScale *= newFrameSize.width / PixCropFrame.width
        self.imageView.transform = CGAffineTransform(scaleX: PixCropImage.transformScale.x * newZoomScale, y: PixCropImage.transformScale.y * newZoomScale).rotated(by: PixCropImage.degreeToRadian())
        /* Image 좌표 변환 */
        // 1. viewSize 변경 전 Frame과 Image의 TopLeading 좌표를 구함
        let frameTopLeading = LayoutUtils.topLeadingPosition(size: PixCropFrame.size, centerPosition: PixCropFrame.center)
        let imageTopLeading = PixCropImage.position(for: .topLeading)
        // 2. viewSize 변경 후 Frame과 Image의 TopLeading 좌표를 구함
        let newFrameTopLeading = LayoutUtils.topLeadingPosition(size: newFrameSize, centerPosition: viewCenter)
        let frameScale = min(newFrameSize.width / previousFrameSize.width, newFrameSize.height / previousFrameSize.height)
        let newImageTopLeading = CGPoint(
            x: newFrameTopLeading.x + (imageTopLeading.x - frameTopLeading.x) * frameScale,
            y: newFrameTopLeading.y + (imageTopLeading.y - frameTopLeading.y) * frameScale
        )
        // 3. 현재 ImageTopLeading을 구해 newImageTopLeading과 값을 동일하게 함
        let currentImageTopLeading = LayoutUtils.topLeadingPosition(
            size:
                CGSize(
                    width: PixCropImage.size.width * newZoomScale,
                    height: PixCropImage.size.height * newZoomScale)
            ,
            centerPosition: PixCropImage.center)
        
        self.imageView.center.x += newImageTopLeading.x - currentImageTopLeading.x
        self.imageView.center.y += newImageTopLeading.y - currentImageTopLeading.y
        /* MaskOverlayView update */
        self.overlayView.update(
            maskSize: newFrameSize,
            maskPosition: LayoutUtils.topLeadingPosition(
                size: newFrameSize,
                centerPosition: viewCenter
            )
        )
    }
}
