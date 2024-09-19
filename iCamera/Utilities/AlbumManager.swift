//
//  AlbumManager.swift
//  iCamera
//
//  Created by 홍승아 on 9/14/24.
//

import Foundation
import Photos
import UIKit

struct Album: Identifiable, Hashable {
    var id = UUID()
    var image: UIImage?
    var name: String
    var asset: PHAssetCollection
}

class AlbumManager: ObservableObject {
    @Published var albums: [Album] = []
    @Published var images: [UIImage] = []
    
    var currentAlbum: Album?
    
    var page: Int = 0
    var isLoading: Bool = false

    // 사진 라이브러리 접근 권한 요청
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
               
            } else {
                print("권한이 거부되었습니다.")
            }
        }
    }
    
    func fetchAlbums() async throws {
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
            print(collection.assetCollectionSubtype.rawValue)
            print(collection.localizedTitle)
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
    
    func fetchPhotos() async throws {
        if isLoading{
            return
        }
        
        isLoading = true
        
        if page < 2 {
            DispatchQueue.main.async {
                self.images = []
            }
        }
        
        let limit = 30
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

        var fetchResult = PHFetchResult<PHAsset>()
        
        if let album = currentAlbum {
            fetchResult = PHAsset.fetchAssets(in: album.asset, options: fetchOptions)
        } else {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        
        let photosCount = fetchResult.count
        
        let imageManager = PHImageManager.default()

        fetchResult.enumerateObjects { (asset, index, stop) in
            if index >= limit * (self.page - 1) && index < limit * self.page{
                let imageSize = CGSize(width: 200, height: 200)

                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = false
                requestOptions.deliveryMode = .highQualityFormat
                requestOptions.isNetworkAccessAllowed = true

                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.images.append(image)
                            print("⭐️ index: \(index)")
                            
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
                return
            }
        }
    }
    
    func resetAlbum(_ album: Album?){
        self.currentAlbum = album
        self.page = 0
        self.isLoading = false
    }
}
