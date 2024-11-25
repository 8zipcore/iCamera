//
//  AlbumManager.swift
//  iCamera
//
//  Created by 홍승아 on 9/14/24.
//

import Foundation
import Photos
import UIKit
import Combine

enum AlbumError: Error{
    case loading
}

struct Album: Identifiable, Hashable {
    var id = UUID()
    var image: UIImage?
    var name: String
    var asset: PHAssetCollection
}

class AlbumManager: ObservableObject {
    @Published var albums: [Album] = []
    @Published var images: [UIImage] = []
    @Published var selectedImage: UIImage?
    
    var currentAlbum: Album?
    
    var page: Int = 0
    var isLoading: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    func fetchAlbums() -> AnyPublisher<Void, Error>{
        Future { promise in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            
            var albumResult: [PHAssetCollection] = []
            
            let categoryOrder: [PHAssetCollectionSubtype] = [
                .smartAlbumUserLibrary,
                .smartAlbumFavorites,
                .smartAlbumSelfPortraits,
                .smartAlbumLivePhotos,
                .smartAlbumDepthEffect,
                .smartAlbumPanoramas,
                .smartAlbumTimelapses,
                .smartAlbumBursts,
                .smartAlbumScreenshots,
            ]
            
            var categorizedCollections = [PHAssetCollectionSubtype: PHAssetCollection]()
            
            // 시스템 앨범 (Camera Roll, Favorites 등)
            let systemAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: fetchOptions)
            
            systemAlbums.enumerateObjects { collection, _, _ in
                if let subtype = PHAssetCollectionSubtype(rawValue: collection.assetCollectionSubtype.rawValue) {
                    categorizedCollections[subtype] = collection
                }
            }
            
            for subtype in categoryOrder {
                if let collection = categorizedCollections[subtype] {
                    albumResult.append(collection)
                }
            }
            
            // 사용자 생성 앨범
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
            
            userAlbums.enumerateObjects { collection, _, _ in
                if !albumResult.contains(collection){
                    albumResult.append(collection)
                }
            }
            
            // 첫 번째 사진 가져오기
            let assetsFetchOptions = PHFetchOptions()
            assetsFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            assetsFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            assetsFetchOptions.fetchLimit = 1
            
            albumResult.forEach{ collection in
                let fetchResult = PHAsset.fetchAssets(in: collection, options: assetsFetchOptions)
                
                if let firstAsset = fetchResult.firstObject{
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 300, height: 300)
                    
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.deliveryMode = .highQualityFormat // 이걸 안해주면 requstImage할 때 저품질, 고품질 두 번 불러옴
                    requestOptions.isSynchronous = true
                    
                    imageManager.requestImage(for: firstAsset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                        let album = Album(image: image, name: collection.localizedTitle ?? "-", asset: collection)
                        DispatchQueue.main.async {
                            self.albums.append(album)
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchPhotos() -> AnyPublisher<Void, Error>{
        Future { promise in
            if self.isLoading{
                promise(.failure(AlbumError.loading))
            }
            
            self.isLoading = true
            
            if self.page < 2 {
                DispatchQueue.main.async {
                    self.images = []
                }
            }
            
            print(self.page)
            
            let limit = 30
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            var fetchResult = PHFetchResult<PHAsset>()
            
            if let album = self.currentAlbum {
                fetchResult = PHAsset.fetchAssets(in: album.asset, options: fetchOptions)
            } else {
                fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            }
            
            let photosCount = fetchResult.count
            
            let imageManager = PHImageManager.default()
            
            fetchResult.enumerateObjects { (asset, index, stop) in
                if index >= limit * (self.page - 1) && index < limit * self.page{
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = false
                    requestOptions.deliveryMode = .highQualityFormat
                    requestOptions.version = .current // 최신 버전 이미지 요청
                    requestOptions.isNetworkAccessAllowed = true
                    
                    DispatchQueue.main.async {
                        self.images.append(UIImage())
                    }
                    
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { image, _ in
                        if let image = image {
                            DispatchQueue.main.async {
                                self.images[index] = image
                                if index == (limit * self.page) - 1 || index == photosCount - 1{
                                    print("⭐️ Loading end")
                                    self.isLoading = false
                                }
                            }
                        }
                    }
                }
                
                if index > limit * self.page{
                    stop.pointee = true // 열거 중단
                    promise(.success(()))
                    return
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchSelectedPhoto(for index: Int) -> AnyPublisher<UIImage, Error>{
        Future { promise in
            DispatchQueue.main.async {
                self.selectedImage = nil
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            var fetchResult = PHFetchResult<PHAsset>()
            
            if let album = self.currentAlbum {
                fetchResult = PHAsset.fetchAssets(in: album.asset, options: fetchOptions)
            } else {
                fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            }
            let asset = fetchResult.object(at: index)
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
            
            let imageManager = PHImageManager.default()
            imageManager.requestImage(for: asset,
                                      targetSize: PHImageManagerMaximumSize, // 고해상도 요청
                                      contentMode: .aspectFill,
                                      options: requestOptions) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.selectedImage = image
                        promise(.success(image))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchRecentlyPhoto() -> AnyPublisher<Void, Error>{
        Future { promise in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            fetchOptions.fetchLimit = 1

            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            let imageManager = PHImageManager.default()
            
            if let asset = fetchResult.firstObject{
                let imageSize = CGSize(width: 200, height: 200)

                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = false
                requestOptions.deliveryMode = .fastFormat

                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.images.append(image)
                            promise(.success(()))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func resetAlbum(_ album: Album?){
        self.currentAlbum = album
        self.page = 0
        self.isLoading = false
    }
    
    func saveImageToPhotos(image: UIImage, completion: @escaping () -> Void) {
        // 사진 라이브러리 접근 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // 권한이 허용되었을 때 이미지 저장
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }, completionHandler: { success, error in
                    if success {
                        print("Image saved to Photos.")
                        completion()
                    } else {
                        print("Error saving image: \(String(describing: error))")
                    }
                })
                
            case .denied, .restricted:
                print("Permission denied or restricted.")
                
            case .notDetermined:
                // 권한이 결정되지 않았으면 다시 요청
                PHPhotoLibrary.requestAuthorization { newStatus in
                    // 권한 요청 후 결과 처리
                }
                
            default:
                break
            }
        }
    }
    
    func resetPage(){
        page = 0
    }
}
