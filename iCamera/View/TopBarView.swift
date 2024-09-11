//
//  TopBarView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct TopBarView: View {
    
    @State var title: String
    
    @State var imageSize: CGSize
    
    var body: some View {
        
        ZStack {
            
            // Colors.skyBlue
            Image("topBar", bundle: nil)
                .resizable()
                .frame(width: imageSize.width, height: imageSize.height)
            
             Text(title)
                .foregroundColor(Colors.titleBlack)
                .font(.system(size: 20, weight: .semibold))
        }
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(title: "iCamera", imageSize: CGSize(width: 500, height: 30))
    }
}
