//
//  AlbumView.swift
//  iCamera
//
//  Created by 홍승아 on 9/14/24.
//

import SwiftUI

struct AlbumView: View {
  @Binding var navigationPath: NavigationPath
  @State var albums: [Album]
  var onTap: (Album) -> Void
  
  var body: some View {
    GeometryReader { geometry in
      
      let viewWidth = geometry.size.width
      
      let albumCellWidth = viewWidth * 0.93
      let albumCellHeight = albumCellWidth * 240 / 1025
      
      ScrollView {
        ForEach(albums.indices, id: \.self) { index in
          let album = albums[index]
          
          VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 20) {
              Group {
                if let image = album.image {
                  Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                } else {
                  Image("default_thumbnail")
                    .resizable()
                    .scaledToFill()
                }
              }
              .frame(width: albumCellHeight * 0.7, height: albumCellHeight * 0.7)
              .cornerRadius(5)
              
              Text(album.name)
                .foregroundStyle(Color.black)
                .font(.system(size: 15, weight: .medium))
              Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
              onTap(album)
            }
            
            Spacer()
            
            if !(index == albums.count - 1) {
              Rectangle()
                .fill(Color.silver.opacity(0.8))
                .frame(width: albumCellWidth, height: 0.8)
            }
          }
          .frame(width: albumCellWidth, height: albumCellHeight)
          .position(x: viewWidth / 2, y: (albumCellHeight / 2))
        }
        
        Spacer()
      }
      .scrollIndicators(.hidden)
      .background(.white)
      .ignoresSafeArea(edges: .bottom)
    }
  }
}
