//
//  GalleryView.swift
//  iCamera
//
//  Created by 홍승아 on 9/13/24.
//

import SwiftUI
import Photos

struct GalleryView: View {
  enum PreviousViewType {
    case main, camera, comments
  }
  
  @Environment(\.dismiss) var dismiss
  
  @Binding var navigationPath: NavigationPath
  var viewType: PreviousViewType
  @State var calendarManager = CalendarManager()
  
  @StateObject var albumVM = AlbumViewModel()
  
  @State private var isShowingAlbumView = false
  @State private var selectedAsset: PHAsset = PHAsset()
  
  private var albumView: some View {
    AlbumView(
      navigationPath: $navigationPath,
      albums: albumVM.albums
    ) { album in
      isShowingAlbumView = false
      
      Task {
        await albumVM.resetAlbum(album)
        loadPhotos()
      }
    }
  }
  
  var body: some View {
    VStack(spacing: .zero) {
      if isShowingAlbumView {
        albumView
      } else {
        galleryCollectionView()
      }
      
      Spacer()
    }
    .navigationBar(
      .gallry,
      trailingButtonType: .cancel,
      onTrailingButtonTap: {
        navigationPath.removeLast(navigationPath.count)
      },
      centerButtonRotated: $isShowingAlbumView,
      onCenterButtonTap: {
        isShowingAlbumView.toggle()
      }
    )
    .background(.white)
    .ignoresSafeArea(edges: .bottom)
    .navigationDestination(for: PHAsset.self) { asset in
      EditPhotoView(
        navigationPath: $navigationPath,
        asset: asset,
        albumManager: albumVM
      )
    }
    .onAppear{
      loadPhotos(includeAlbums: true)
    }
  }
}

extension GalleryView {
  private func loadPhotos(includeAlbums: Bool = false) {
    Task {
      let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
      
      switch status {
      case .authorized:
        albumVM.fetchPhotos()
        if includeAlbums {
          await albumVM.fetchAlbums()
        }
      default:
        print("사진 라이브러리 접근 권한이 없습니다.")
      }
    }
  }
}

extension GalleryView {
  private func galleryCollectionView() -> some View {
    GeometryReader { geometry in
      let cellSpcacing: CGFloat = 3
      let columnNumber: CGFloat = 3
      let cellWidth = (geometry.size.width - (columnNumber - 1) * cellSpcacing) / columnNumber
      
      GalleryCollectionView(
        assets: $albumVM.assets,
        itemSize: CGSize(width: cellWidth, height: cellWidth),
        spacing: 3,
        onTap: { asset in
          selectedAsset = asset
          
          if viewType == .comments {
            calendarManager.selectedImage.send((albumVM, asset))
            dismiss()
          } else {
            navigationPath.append(asset)
          }
        }
      )
    }
  }
}
