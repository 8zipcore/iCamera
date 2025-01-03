//
//  AlbumView.swift
//  iCamera
//
//  Created by 홍승아 on 9/14/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct AlbumView: View {
    @Binding var navigationPath: NavigationPath
    
    @State var albumManager: AlbumManager
    
    var action: (Album) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            
            let viewWidth = geometry.size.width
            
            let albumCellWidth = viewWidth * 0.93
            let albumCellHeight = albumCellWidth * 240 / 1025
            
            Color.white
            
            ScrollView{
                ForEach(albumManager.albums.indices, id: \.self) { index in
                    let album = albumManager.albums[index]
                    VStack(spacing: 0){
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Image(uiImage: album.image ?? .test)
                                .resizable()
                                .scaledToFill()
                                .frame(width: albumCellHeight * 0.7, height: albumCellHeight * 0.7)
                                .cornerRadius(5)
                            
                            Text(album.name)
                                .foregroundStyle(Color.black)
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            action(album)
                        }
                        
                        Spacer()
                        
                        if !(index == albumManager.albums.count - 1){
                            Rectangle()
                                .fill(Colors.silver.opacity(0.8))
                                .frame(width: albumCellWidth, height: 0.8)
                        }
                    }
//                    .padding(.top, -8) // VStack 최소 spacing이 8이라 여백없애줌
                    .frame(width: albumCellWidth, height: albumCellHeight)
                    .position(x: viewWidth / 2, y: (albumCellHeight / 2))
                }
            }
            .background(.white)
            .padding(.top, 8)
        }
    }
}
