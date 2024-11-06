//
//  CalendarCell.swift
//  iCamera
//
//  Created by 홍승아 on 10/30/24.
//

import SwiftUI

struct CalendarCell: View {
    var day: String
    var image: UIImage?
    var hiddenBottomLine: Bool = false
    
    var body: some View {
        let lineWidth: CGFloat = 1
        let lineColor: Color = Colors.silver.opacity(0.5)
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            ZStack{
                if let image = image {
                    let imageSize = imageSize(image: image, viewWidth: viewWidth, viewHeight: viewHeight)
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .position(x: viewWidth / 2, y: viewHeight / 2)
                        .clipped()
                }
                HStack{
                    Spacer()
                    Rectangle()
                        .fill(lineColor)
                        .frame(width: lineWidth)
                }
                VStack{
                    Rectangle()
                        .fill(lineColor)
                        .frame(height: lineWidth)
                    HStack{
                        Spacer()
                        Text(day)
                            .font(.system(size: 12))
                            .foregroundStyle(.black)
                    }
                    .padding(.trailing, 5)
                    // .zIndex(1)
                    Spacer()
                    Rectangle()
                        .fill(lineColor)
                        .frame(height: lineWidth)
                        .hidden(hiddenBottomLine)
                }
            }
            .background(.white)
        }
    }
    
    private func imageSize(image: UIImage, viewWidth: CGFloat, viewHeight: CGFloat) -> CGSize{
        var imageWidth = image.size.width * viewHeight / image.size.height
        var imageHeight = viewHeight
        if imageWidth < viewWidth {
            imageWidth = viewWidth
            imageHeight = image.size.height * viewWidth / image.size.width
        }
        return CGSize(width: imageWidth, height: imageHeight)
    }
}
