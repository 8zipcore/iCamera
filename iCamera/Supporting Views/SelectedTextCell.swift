//
//  SelectedTextCell.swift
//  iCamera
//
//  Created by 홍승아 on 11/11/24.
//

import SwiftUI

struct SelectedTextCell: View {
    var title: String
    var font: Font
    var isSelected: Bool
    
    @State private var textSize: CGSize = .zero
    
    var body: some View {
        ZStack{
            if isSelected{
                Image("selected")
                    .resizable()
                    .frame(width: textSize.width, height: 40)
            }
            Text(title)
                .font(font)
                .padding([.leading, .trailing], 10)
                .foregroundStyle(.black)
                .background(
                    GeometryReader{ geometry in
                        Color.clear.onAppear{
                            textSize = geometry.size
                        }
                    }
                )
        }
    }
}
/*
#Preview {
    SelectedTextCell(title: "Tfdfddffdfdfdfdfdfdfdfdfddfdf", font: .system(size: 15), isSelected: true)
}
*/
