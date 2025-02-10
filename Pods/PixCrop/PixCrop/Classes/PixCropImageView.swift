//
//  PixCropImageView.swift
//  Pods
//
//  Created by 홍승아 on 1/31/25.
//

import Foundation

public class PixCropImageView: UIImageView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(){
        self.contentMode = .scaleAspectFill
    }

    func setImage(_ image: UIImage){
        self.image = image
    }
}
