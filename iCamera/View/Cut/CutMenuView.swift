//
//  CutMenuView.swift
//  iCamera
//
//  Created by 홍승아 on 11/9/24.
//

import SwiftUI

struct CutMenuView: View {
    
    @StateObject var cutImageManager: CutImageManager
    @StateObject var pixCropManager: PixCropManager
    
    var body: some View {
        HStack(spacing: 0){
            Button(action: {
                pixCropManager.flipHorizontally()
            }) {
                Image("flip_horizontally")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 25)
            }
            
            Button(action: {
                pixCropManager.rotateLeft()
            }) {
                Image("rotation")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
            }
            
            VStack{
                if cutImageManager.currentRatioDirection == .vertical{
                    Image("ratio_direction")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .padding(.top, 3)
                } else {
                    Image("ratio_direction")
                        .resizable()
                        .rotationEffect(.degrees(90))
                        .frame(width: 26, height: 26)
                        .padding(.top, 3)
                }
            }
            .onTapGesture {
                cutImageManager.ratioDriectionToggle()
            }
        }
    }
}
