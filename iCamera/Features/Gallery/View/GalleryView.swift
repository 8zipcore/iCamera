//
//  GalleryView.swift
//  iCamera
//
//  Created by 홍승아 on 9/13/24.
//

import SwiftUI
import Photos

@available(iOS 16.0, *)
struct GalleryView: View {
    enum PreviousViewType{
        case main, camera, comments
    }
    
    @Binding var navigationPath: NavigationPath
    var viewType: PreviousViewType
    @State var calendarManager = CalendarManager()
    
    @StateObject var albumManager = AlbumManager()
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    
    @State private var isShowingAlbumView = false
    
    @State private var isNavigating: Bool = false
    @State private var selectedAsset: PHAsset = PHAsset()
    
    @Environment(\.dismiss) var dismiss
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                VStack(spacing: 0){
                    
                    let topBarSize = topBarViewButtonManager.topBarViewSize(viewWidth: viewWidth)
                    
                    TopBarView(title: "Photos",
                               imageSize: topBarSize,
                               isLeadingButtonHidden: viewType == .main,
                               isTrailingButtonHidden: false,
                               isAlbumButtonHidden: false,
                               buttonManager: topBarViewButtonManager)
                    .frame(width: topBarSize.width, height: topBarSize.height)
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        switch buttonType{
                        case .cancel:
                            dismiss()
                        case .home:
                            navigationPath.removeLast(navigationPath.count)
                        case .album:
                            isShowingAlbumView = true
                        default:
                            break
                        }
                    }
                    
                    if isShowingAlbumView {
                        AlbumView(navigationPath: $navigationPath, albumManager: albumManager){ album in
                            isShowingAlbumView = false
                            Task{
                                await albumManager.resetAlbum(album)
                                loadPhotos()
                            }
                        }
                    } else {
                        let cellSpcacing: CGFloat = 3
                        let columnNumber: CGFloat = 3
                        let cellWidth = (viewWidth - (columnNumber - 1) * cellSpcacing) / columnNumber
                        
                        NavigationLink(
                            destination: EditPhotoView(
                                navigationPath:$navigationPath,
                                asset: selectedAsset,
                                albumManager: albumManager),
                            isActive: $isNavigating
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        
                        GalleryCollectionView(
                            albumManager: albumManager,
                            itemSize: CGSize(width: cellWidth, height: cellWidth),
                            spacing: 3,
                            onTap: { asset in
                                selectedAsset = asset
                                if viewType == .comments {
                                    calendarManager.selectedImage.send((albumManager, asset))
                                    dismiss()
                                } else {
                                    isNavigating = true
                                }
                            }
                        )
                    }
                }
                .background(.white)
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            loadPhotos()
            albumManager.fetchAlbums()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ 앨범 불러오기 완료")
                    case .failure(_):
                        print("🌀 앨범 불러오기 오류")
                    }
                }, receiveValue: {})
                .store(in: &albumManager.cancellables)
        }
    }
    
    func loadPhotos(){
        print("✅ 사진 불러오기 시작")
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                albumManager.fetchPhotos()
                    .sink(receiveCompletion: { completion in
                        switch completion{
                        case .finished:
                            print("✅ 사진 불러오기 완료")
                        case .failure(let error):
                            print("🌀 error : \(error)")
                        }
                    }, receiveValue: {})
                    .store(in: &albumManager.cancellables)
            } else {
                print("사진 라이브러리 접근 권한이 없습니다.")
            }
        }
    }
    
    /*
    private func visibleAssets() -> [PHAsset?] {
        return Array(albumManager.assets.prefix(visibleRange.upperBound))
    }

    private func updateVisibleRange(using proxy: GeometryProxy, imageWidth: CGFloat, topBarViewHeight: CGFloat) {
        let scrollPosition = topBarViewHeight - proxy.frame(in: .global).minY
        let startIndex = max(Int(scrollPosition / imageWidth) * 3, 0)
        let endIndex = min(startIndex + 30, 11532)
        visibleRange = startIndex..<endIndex
        print(visibleRange)
    }
     */
}

