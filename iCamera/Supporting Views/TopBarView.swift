//
//  TopBarView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI
import Combine

enum TopBarViewButtonType{
    case cancel, home, album, confirm
}

class TopBarViewButtonManager: ObservableObject {
    var buttonClicked = PassthroughSubject<TopBarViewButtonType, Never>()
    var cancellables = Set<AnyCancellable>()
    
    func topBarViewSize(viewWidth: CGFloat) -> CGSize{
        return CGSize(width: viewWidth, height: viewWidth * 3 / 25)
    }
}

struct TopBarView: View {
    
    @State var title: String
    @State var imageSize: CGSize
    @State var isLeadingButtonHidden: Bool = true
    @State var isTrailingButtonHidden: Bool = true
    @State var trailingButtonType: TopBarViewButtonType = .home
    @State var isAlbumButtonHidden: Bool = true
    
    @ObservedObject var buttonManager: TopBarViewButtonManager

    var body: some View {
        
        ZStack {
            Image("topBar", bundle: nil)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize.width, height: imageSize.height)
            
            HStack(spacing: 0){
                let buttonPadding: CGFloat = 12
                let buttonWidth: CGFloat = imageSize.height * 0.75
                
                if !isLeadingButtonHidden{
                    Button(action: {
                        print("⭐️ xButton Tapped!")
                        buttonManager.buttonClicked.send(.cancel)
                    }) {
                        Image("xmark_button")
                            .resizable()
                            .frame(width: buttonWidth, height: buttonWidth)
                    }
                    .padding(.leading, buttonPadding)
                }
                Spacer()
                if !isTrailingButtonHidden{
                    Button(action: {
                        print("⭐️ homeButton Tapped!")
                        buttonManager.buttonClicked.send(trailingButtonType)
                    }) {
                        Image(trailingButtonImageName())
                            .resizable()
                            .frame(width: buttonWidth, height: buttonWidth)
                    }
                    .padding(.trailing, buttonPadding)
                }
            }
            
            HStack{
                Text(title)
                   .foregroundColor(Colors.titleBlack)
                   .font(.system(size: 20, weight: .semibold))
                
                if !isAlbumButtonHidden{
                    Button(action: {
                        print("⭐️ AlbumListButton Tapped!")
                        buttonManager.buttonClicked.send(.album)
                    }) {
                        Image("triangle_button")
                            .resizable()
                            .frame(width: 12, height: 10)
                    }
                    .padding(.top, 3)
                    .padding(.leading, 3)
                    .frame(width: 20, height: 20)
                }
            }

        }
    }
    
    private func trailingButtonImageName() -> String{
        switch trailingButtonType {
        case .home:
            return "home_button"
        case .confirm:
            return "confirm_button"
        default:
            return ""
        }
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(title: "iCamera", imageSize: CGSize(width: 400, height: 30), buttonManager: TopBarViewButtonManager())
    }
}
