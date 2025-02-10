//
//  Extension+.swift
//  PixCrop
//
//  Created by 홍승아 on 1/10/25.
//

import Foundation

extension UIImageView{
    func flip(_ transformScale: CGPoint){
        self.transform = CGAffineTransform(scaleX: transformScale.x, y: transformScale.y)
    }
    
    func rotate(_ degree: CGFloat){
        self.transform = CGAffineTransform(rotationAngle: degree)
    }
}
