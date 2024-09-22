//
//  TopBarView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI
import Combine

enum TopBarViewButtonType{
    case cancel, home, album
}

class TopBarViewButtonManager: ObservableObject {
    var buttonClicked = PassthroughSubject<TopBarViewButtonType, Never>()
}

struct TopBarView: View {
    
    @State var title: String
    @State var imageSize: CGSize
    @State var isLeadingButtonHidden: Bool = true
    @State var isTrailingButtonHidden: Bool = true
    @State var isAlbumButtonHidden: Bool = true
    @State var trailingButtonImage = "home_button"
    
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
                        buttonManager.buttonClicked.send(.home)
                    }) {
                        Image(trailingButtonImage)
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
        .frame(width: imageSize.width)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(title: "iCamera", imageSize: CGSize(width: 400, height: 30), buttonManager: TopBarViewButtonManager())
    }
}
