//
//  FilterTypeCell.swift
//  iCamera
//
//  Created by 홍승아 on 11/27/24.
//

import SwiftUI

struct FilterTypeCell: View {
    
    var filter: Filter
    
    @State private var filterManager = FilterManager()
    
    var body: some View {
        GeometryReader{ geometry in
            let viewWidth = geometry.size.width
            ZStack{
                if let filterImage = filterManager.previewFilterImage(filter: filter){
                    Image(uiImage: filterImage)
                        .resizable()
                        .scaledToFill()
                }
                
                VStack{
                    Spacer()
                    ZStack{
                        Rectangle()
                            .fill(.black.opacity(0.4))
                        
                        Text(filter.title)
                            .font(.system(size: 11))
                            .foregroundStyle(.white)
                    }
                    .frame(width: viewWidth, height: viewWidth * 56 / 239 )
                }
            }
        }
    }
}
