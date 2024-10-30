//
//  CalendarCellView.swift
//  iCamera
//
//  Created by 홍승아 on 10/30/24.
//

import SwiftUI

struct CalendarCellView: View {
    var day: String
    var image: UIImage?
    var hiddenBottomLine: Bool = false
    
    var body: some View {
        let lineWidth: CGFloat = 1
        let lineColor: Color = Colors.silver.opacity(0.5)
        ZStack{
            if let image = image {
                Image(uiImage: image)
                    .resizable()
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
                        .font(Font(UIFont.systemFont(ofSize: 10, weight: .medium)))
                }
                .padding(.trailing, 5)
                Spacer()
                Rectangle()
                    .fill(lineColor)
                    .frame(height: lineWidth)
                    .hidden(hiddenBottomLine)
            }
        }
    }
}

#Preview {
    CalendarCellView(day: "1", image: nil, hiddenBottomLine: false)
}
