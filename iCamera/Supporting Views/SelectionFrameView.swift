//
//  SelectionFrameView.swift
//  iCamera
//
//  Created by 홍승아 on 10/5/24.
//

import SwiftUI

struct SelectionFrameView: View{
    var imageWidth: CGFloat
    var imageHeight: CGFloat
    var lineSize: CGSize
    
    @State var cutImageManager: CutImageManager
    
    @State private var isFrameDrag: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            ZStack{
                Rectangle()
                    .stroke(Color.black, lineWidth: 1)
                    .background(.clear)
                    .frame(width: imageWidth, height: imageHeight)
                    .position(x: viewWidth / 2, y: viewHeight / 2)
                
                let selectionFrameRectangleArray = SelectionFrameRectangle.Location.allCases.map{ location in
                    return SelectionFrameRectangle(location: location)
                }
                
                let lineWidth = lineSize.width
                let lineHeight = lineSize.height
                
                ForEach(selectionFrameRectangleArray, id:\.self){ rectangle in
                    let rectangleSize = CGSize(width: lineSize.height, height: lineSize.height)
                    let maskRectangleSize = rectangle.maskRectangleSize(lineSize: lineSize)
                    let maskPosition = rectangle.maskPosition(lineSize: lineSize)
                    let x: CGFloat = (viewWidth / 2) + ((imageWidth / 2) - (lineHeight / 2 - lineWidth)) * rectangle.scale.x
                    let y: CGFloat = (viewHeight / 2) + ((imageHeight / 2) - (lineHeight / 2 - lineWidth)) * rectangle.scale.y
                    
                    MaskRectangleView(overlayColor: .black,
                                      rectangleSize: rectangleSize,
                                      maskRectangleSize: maskRectangleSize,
                                      maskPosition: maskPosition)
                    .frame(width: rectangleSize.width, height: rectangleSize.height)
                    .position(x: x, y: y)
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                let data = SelectionFrameRectangleData(selectionFrameRectangle: rectangle, position: value.location)
                                cutImageManager.selectionFrameDrag.send(data)
                            }
                            .onEnded{ value in
                                isFrameDrag = false
                                let movingValuePoint = CGPoint(x: value.location.x - value.startLocation.x, y: value.location.y - value.startLocation.y)
                                let data = SelectionFrameRectangleData(selectionFrameRectangle: rectangle, position: movingValuePoint)
                                cutImageManager.selectionFrameDragEnded.send(data)
                            }
                    )
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        if isFrameDrag {
                            return
                        }
                        cutImageManager.imageZoom.send(value)
                    }
                    .onEnded{ _ in
                        cutImageManager.imageZoomEnded.send()
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged{ value in
                        if isFrameDrag { return }
                        
                        let startLocation = value.startLocation
                        
                        let plusTouchAreaSize: CGFloat = 5
                        
                        if startLocation.x <= lineSize.height + plusTouchAreaSize ||
                            startLocation.x >= viewWidth - lineSize.height - plusTouchAreaSize ||
                            startLocation.y <= lineSize.height + plusTouchAreaSize ||
                            startLocation.y >= viewHeight - lineSize.height - plusTouchAreaSize
                        {
                            print("frameDrag")
                            isFrameDrag = true
                            return
                        }
                        
                        
                        let movingValuePoint = CGPoint(x: value.location.x - startLocation.x, y: value.location.y - startLocation.y)
                        cutImageManager.imageDrag.send(movingValuePoint)
                    }
                    .onEnded{ value in
                        cutImageManager.imageDragEnded.send(value.location)
                    }
            )
            .background(.clear)
        }
    }
}
