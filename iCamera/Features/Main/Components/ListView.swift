//
//  ListView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct ListView: View {
  
  @State var title: String
  
  var body: some View {
    HStack {
      Text(title)
        .multilineTextAlignment(.leading)
        .font(.system(size: 18, weight: .semibold))
        .foregroundColor(.black)
      
      Spacer()
      
      Image("arrow")
        .resizable()
        .frame(width: 16, height: 16)
    }
    .contentShape(Rectangle())
  }
}
