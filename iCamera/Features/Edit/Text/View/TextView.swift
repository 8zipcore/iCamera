//
//  TextView.swift
//  iCamera
//
//  Created by 홍승아 on 10/23/24.
//

import SwiftUI

struct TextView: View {
  enum TextUpdateType {
    case font, input, initial
  }
  
  var index: Int
  var textData: TextData
  @State var textSize: CGSize = .zero
  @StateObject var textManager: TextManager
  @StateObject var editManager: EditManager
  var editImageViewPositionArray: [CGPoint]
  @State var textBackgroundSizes: [CGSize] = []
  @State var updateType: TextUpdateType = .initial
  @State var containerSize: CGSize = .zero
  
  @State private var lastUpdate: Date = .distantPast
  @State private var showRectangle = false
  @State private var isHidden = true
  
  private let horizontalPadding: CGFloat = 20
  private let verticalPadding: CGFloat = 40
  private let buttonWidth: CGFloat = 20
  
  private var textSelectionSize: CGSize {
    CGSize(
      width: textSize.width + horizontalPadding,
      height: textSize.height + verticalPadding
    )
  }
  
  private var textOffset: CGPoint {
    let y = (textSelectionSize.height - textSize.height) / 2
    let x: CGFloat
    switch textData.textAlignment {
    case .left:
      x = (textSelectionSize.width - textSize.width) / 2
    case .right:
      x = -(textSelectionSize.width - textSize.width) / 2
    default:
      x = 0
    }
    return CGPoint(x: x, y: y)
  }
  
  var body: some View {
    ZStack {
      text()
        .overlay {
          if textData.isSelected && showRectangle {
            textSelectionOverlay()
              .frame(width: textSelectionSize.width, height: textSelectionSize.height)
          }
        }
    }
    .background { textBackgrounds() }
    .rotationEffect(textData.angle)
    .frame(width: textSelectionSize.width, height: textSelectionSize.height)
    .contentShape(Rectangle())
    .onAppear {
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(0.03))
        textSize = textData.size
        textBackgroundSizes = textData.textBackgroundSizes
        isHidden = false
        showRectangle = true
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .saveTextInfo)) { _ in
      textManager.textArray[index].textBackgroundSizes = textBackgroundSizes
      textManager.textArray[index].size = textSize
      textManager.completeSaveTextInfo.send()
    }
    .gesture(makeGestures())
  }
}

// MARK: - Subviews & Gestures
extension TextView {
  
  private func yOffset(idx: Int) -> CGFloat {
    let size = textBackgroundSizes[idx]
    let counts = textBackgroundSizes.count
    let middle = floor(CGFloat(counts) / 2)
    let result = size.height / 2 * (CGFloat(idx) - middle + (counts % 2 == 0 && idx >= Int(middle) ? 1 : 0))
    return result
  }
  
  @ViewBuilder
  private func textBackgrounds() -> some View {
    ForEach(textBackgroundSizes.indices, id: \.self) { idx in
      let size = textBackgroundSizes[idx]
      let yOffset: CGFloat = yOffset(idx: idx)
      
      Rectangle()
        .fill(textData.backgroundColor)
        .frame(width: size.width, height: size.height)
        .offset(
          x: textOffset.x,
          y: yOffset
        )
    }
  }
  
  @ViewBuilder
  private func text() -> some View {
    NonEditableCustomTextView(
      textData: .constant(textData),
      containerWidth: containerSize.width
    ) { newSizes, newSize in
      Task { @MainActor in
        let now = Date()
        guard now.timeIntervalSince(lastUpdate) > 0.03 else { return }
        lastUpdate = now
        
        textBackgroundSizes = newSizes
        textSize = newSize
      }
    }
    .offset(x: textOffset.x, y: textOffset.y)
    .onChange(of: textSize) { newSize in
      textManager.textArray[index].size = newSize
    }
  }
  
  @ViewBuilder
  private func textSelectionOverlay() -> some View {
    ZStack {
      xmarkButton()
      
      editButton()
    }
    .background(Rectangle().stroke(.white, lineWidth: 1.5).padding(10))
  }
  
  private func xmarkButton() -> some View {
    VStack {
      
      HStack {
        Image("xmark_button")
          .resizable()
          .frame(width: buttonWidth, height: buttonWidth)
        
        Spacer()
      }
      
      Spacer()
    }
    .onTapGesture { textManager.deleteText(index: index) }
  }
  
  private func editButton() -> some View {
    VStack {
      Spacer()
      
      HStack {
        Spacer()
        
        Image("edit_button")
          .resizable()
          .frame(width: buttonWidth, height: buttonWidth)
      }
    }
    .onTapGesture { textManager.editTextButtonTapped.send() }
  }
  
  private func makeGestures() -> some Gesture {
    SimultaneousGesture(
      SimultaneousGesture(
        MagnificationGesture()
          .onChanged { value in
            if textManager.isSelected(textData) {
              let idx = textManager.textArray.count - 1
              textManager.textArray[idx].scale = value
            }
          },
        RotationGesture()
          .onChanged { value in
            if textManager.isSelected(textData) {
              let idx = textManager.textArray.count - 1
              textManager.textArray[idx].angle = value
            }
          }
      ),
      DragGesture()
        .onChanged { value in
          let translation = CGSize(
            width: textData.location.x + value.translation.width,
            height: textData.location.y + value.translation.height
          )
          if textManager.isFirstDrag {
            textManager.selectText(index: index)
            textManager.isFirstDrag = false
            editManager.selectText.send()
          }
          textManager.setTextLocation(index: index, translation: translation)
        }
        .onEnded { _ in textManager.isFirstDrag = true }
    )
  }
}
