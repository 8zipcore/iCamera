//
//  CustomSlider.swift
//  iCamera
//
//  Created by 홍승아 on 11/13/24.
//

import SwiftUI
import Combine

class CustomSliderManager: ObservableObject{
    var onChange = PassthroughSubject<CGFloat, Never>()
}

struct CustomSlider: View {
    var value: CGFloat = .zero
    @StateObject var customSliderManager: CustomSliderManager
    
    @State var pointerXPosition: CGFloat = .zero
    
    var body: some View {
        GeometryReader{ geometry in
            let barHeight: CGFloat = 13
            let imageWidth: CGFloat = 23
            let minXPosition = imageWidth / 2
            let maxXPosition = geometry.size.width - minXPosition
            ZStack{
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0.05),
                                .init(color: Colors.sliderSliver, location: 1.0)
                            ]),
                            startPoint: .top, // 시작점
                            endPoint: .bottom // 끝점
                        )
                    )
                    .frame(height: barHeight)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                Image("pink_circle")
                    .resizable()
                    .frame(width: imageWidth, height: imageWidth)
                    .position(x: pointerXPosition, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                if value.location.x < minXPosition {
                                    pointerXPosition = minXPosition
                                } else if value.location.x > maxXPosition {
                                    pointerXPosition = maxXPosition
                                } else {
                                    pointerXPosition = value.location.x
                                }
                                let barWidth = geometry.size.width - minXPosition * 2
                                let value = (pointerXPosition - minXPosition) / barWidth
                                customSliderManager.onChange.send(value)
                            }
                            .onEnded{ _ in
                                
                            }
                    )
            }
            .background(.clear)
            .ignoresSafeArea()
            .onAppear{
                pointerXPosition = value == .zero ? minXPosition : (maxXPosition - minXPosition) * value
            }
        }
    }
}
