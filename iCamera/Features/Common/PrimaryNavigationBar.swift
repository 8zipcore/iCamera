//
//  PrimaryNavigationBar.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct PrimaryNavigationBar: View {
  
  enum ViewType {
    case main, camera, edit, save, comments, calendar, gallry
    
    var title: String {
      switch self {
      case .main, .edit, .save:
        return "iCamera"
      case .camera:
        return "Camera"
      case .comments:
        return "Comments"
      case .calendar:
        return "Calendar"
      case .gallry:
        return "Photos"
      }
    }
  }
  
  enum ButtonType {
    case cancel, home, album, confirm, today
    
    var imageName: String {
      switch self {
      case .home:
        return "home_button"
      case .confirm:
        return "confirm_button"
      case .cancel:
        return "xmark_button"
      case .album:
        return "triangle_button"
      case .today:
        return "blue_button"
      }
    }
  }
  
  var viewType: ViewType
  var leadingButtonType: ButtonType?
  var onLeadingButtonTap: (() -> Void)?
  var trailingButtonType: ButtonType?
  var onTrailingButtonTap: (() -> Void)?
  @Binding var centerButtonRotated: Bool
  var onCenterButtonTap: (() -> Void)?
  
  private let buttonSize = CGSize(width: 28, height: 28)
    
  var body: some View {
    ZStack {
      HStack(spacing: 0) {
        leadingButton()
        
        Spacer()
        
        trailingButton()
      }
      
      HStack{
        Text(viewType.title)
          .foregroundColor(.titleBlack)
          .font(.system(size: 20, weight: .semibold))
        
        centerButton()
      }
    }
    .padding(.vertical, .smallPadding)
    .background(
      LinearGradient(
        gradient: Gradient(stops: [
          .init(color: .white, location: 0),
          .init(color: .init(red: 227, green: 249, blue: 255), location: 0.4),
          .init(color: .init(red: 198, green: 244, blue: 255), location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
    )
  }
}

// MARK: - Subviews
extension PrimaryNavigationBar {
  @ViewBuilder
  private func leadingButton() -> some View {
    if let leadingButtonType {
      Button {
        onLeadingButtonTap?()
      } label: {
        switch leadingButtonType {
        case .today:
          Image(ButtonType.today.imageName)
            .resizable()
            .frame(width: 65, height: buttonSize.height)
            .overlay {
              Text("Today")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
            }
        default:
          Image(ButtonType.cancel.imageName)
            .resizable()
            .frame(width: buttonSize.width, height: buttonSize.width)
        }
      }
      .padding(.leading, .mediumPadding)
    }
  }
  
  @ViewBuilder
  private func trailingButton() -> some View {
    if let trailingButtonType {
      Button {
        onTrailingButtonTap?()
      } label: {
        Image(trailingButtonType.imageName)
          .resizable()
          .frame(width: buttonSize.width, height: buttonSize.width)
      }
      .padding(.trailing, .mediumPadding)
    }
  }
  
  @ViewBuilder
  private func centerButton() -> some View {
    if viewType == .gallry {
      Button{
        onCenterButtonTap?()
      } label: {
        Image(ButtonType.album.imageName)
          .resizable()
          .frame(width: 12, height: 10)
          .rotationEffect(.degrees(centerButtonRotated ? 180 : 0))
          .animation(nil, value: centerButtonRotated)
      }
      .padding(.top, 3)
      .padding(.leading, 3)
      .frame(width: 20, height: 20)
    }
  }
}
