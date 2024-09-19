//
//  GalleryView.swift
//  iCamera
//
//  Created by 홍승아 on 9/13/24.
//

import SwiftUI
import Photos

struct GalleryView: View {
    @StateObject private var albumManager = AlbumManager()
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    
    @State private var isShowingAlbumView = false
    
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
                    
                    let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                    
                    TopBarView(title: "Gallery",
                               imageSize: topBarSize,
                               isTrailingButtonHidden: false,
                               isAlbumButtonHidden: false,
                               buttonManager: topBarViewButtonManager)
                    .frame(width: topBarSize.width, height: topBarSize.height)
                    .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                        switch buttonType{
                        case .cancel:
                            break
                        case .home:
                            dismiss()
                        case .album:
                            isShowingAlbumView = true
                        }
                    }
                    
                    if isShowingAlbumView {
                        AlbumView(albumManager: albumManager){ album in
                            isShowingAlbumView = false
                            albumManager.resetAlbum(album)
                            Task{
                                try await loadPhotos()
                            }
                        }
                    } else {
                        let imageViewWidth = viewWidth / 3
                        
                        ScrollViewWithOnScrollChanged(content: {
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(albumManager.images, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: imageViewWidth, height: imageViewWidth)
                                        .background(.clear)
                                        .clipped()
                                }
                            }
                            .background(.white)
                        }, scrollViewDidScroll: { scrollView in
                            // 💡 추측 : SwiftUI로 변환할때 scorllview가 그냥 viewWidth, viewHeight 사이즈로 인식 됨 ??
                            // ㄴ contentOffSet을 scorllView의 진짜크기(viewHeight - scrollView.height)으로 제대로 안받아옴
                            // ㄴ 그래서 scrollView의 height을 viewHeight 기준으로 할 때
                            // ㄴ 전체는 topBarHeight + scorllViewHeight이니까 scrollViewHeight 대신 viewHeight을 넣어줬음
                            // ㄴ 바닥 찍고 불러오니까 약간 부자연스러워서 밑에서 두번째 줄 일때 불러오는걸로 바꿈
                            let scrollViewHeight = viewHeight + topBarSize.height + (imageViewWidth * 2)
                            let minY = scrollView.contentSize.height - scrollView.contentOffset.y
                            
                            if scrollViewHeight >= minY && !albumManager.isLoading{
                                Task{
                                    try await loadPhotos()
                                }
                            }
                        })
                        .frame(height: viewHeight - topBarSize.height) // 이 코드 안먹힘
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            Task{
                try await loadPhotos()
                try await albumManager.fetchAlbums()
            }
        }
    }
    
    func loadPhotos() async throws{
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                albumManager.page += 1
                Task{
                    try await albumManager.fetchPhotos()
                }
            } else {
                print("사진 라이브러리 접근 권한이 없습니다.")
            }
        }
    }
}
    
// PreferenceKey를 사용해 스크롤 오프셋을 추적
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    GalleryView()
}
