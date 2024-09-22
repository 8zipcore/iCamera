//
//  TestView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct TestView: View {
    @Binding var navigationPath: NavigationPath
    @State var image: UIImage
    
    var body: some View {
        GeometryReader { gemotry in
            VStack{
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
            }
        }
    }
}
