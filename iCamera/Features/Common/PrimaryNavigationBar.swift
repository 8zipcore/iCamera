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
    
    var isLeadingButtonHidden: Bool {
      switch self {
      case .main, .edit, .save:
        return true
      default:
        return false
      }
    }
  }
  
  enum ButtonType{
    case cancel, home, album, confirm
    
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
      }
    }
  }
  
  var viewType: ViewType
  var onLeadingButtonTap: (() -> Void)?
  var trailingButtonType: ButtonType?
  var onTrailingButtonTap: (() -> Void)?
  var onCenterButtonTap: (() -> Void)?
  
  private let imageSize = CGSize(width: 25, height: 25)
  
  var body: some View {
    
    ZStack {
      HStack(spacing: 0){
        let buttonWidth: CGFloat = imageSize.height * 0.75
        
        if !viewType.isLeadingButtonHidden {
          Button(action: {
            onLeadingButtonTap?()
          }) {
            Image(ButtonType.cancel.imageName)
              .resizable()
              .frame(width: buttonWidth, height: buttonWidth)
          }
          .padding(.leading, .mediumPadding)
        }
        
        Spacer()
        
        if let trailingButtonType {
          Button(action: {
            onTrailingButtonTap?()
          }) {
            Image(trailingButtonType.imageName)
              .resizable()
              .frame(width: buttonWidth, height: buttonWidth)
          }
          .padding(.trailing, .mediumPadding)
        }
      }
      
      HStack{
        Text(viewType.title)
          .foregroundColor(Colors.titleBlack)
          .font(.system(size: 20, weight: .semibold))
        
        if viewType == .gallry {
          Button(action: {
            onCenterButtonTap?()
          }) {
            Image(ButtonType.album.imageName)
              .resizable()
              .frame(width: 12, height: 10)
          }
          .padding(.top, 3)
          .padding(.leading, 3)
          .frame(width: 20, height: 20)
        }
      }
    }
    .padding(.vertical, .smallPadding)
    .background(
      LinearGradient(
        gradient: Gradient(stops: [
          .init(color: .white, location: 0),
          .init(color: RGB(red: 227, green: 249, blue: 255), location: 0.4),
          .init(color: RGB(red: 198, green: 244, blue: 255), location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
    )
  }
}
