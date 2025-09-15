//
//  AlbumViewModel.swift
//  iCamera
//
//  Created by 홍승아 on 9/14/24.
//

import Foundation
import Photos
import UIKit

final class AlbumViewModel: ObservableObject {
  @Published var albums: [Album] = []
  @Published var images: [UIImage] = []
  @Published var selectedImage: UIImage?
  @Published var assets: [PHAsset] = []
  
  private var fetchOptions: PHFetchOptions {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
    
    return fetchOptions
  }
  
  var currentAlbum: Album?
  var isLoading: Bool = false
  
  private var imageManager = PHCachingImageManager()
  
  func fetchAlbums() async {
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
      .smartAlbumScreenshots
    ]
    
    var categorizedCollections = [PHAssetCollectionSubtype: PHAssetCollection]()
    
    // 시스템 앨범 가져오기
    let systemAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
    
    systemAlbums.enumerateObjects { collection, _, _ in
      categorizedCollections[collection.assetCollectionSubtype] = collection
    }
    
    for subtype in categoryOrder {
      if let collection = categorizedCollections[subtype] {
        albumResult.append(collection)
      }
    }
    
    // 사용자 생성 앨범 추가
    let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
    
    userAlbums.enumerateObjects { collection, _, _ in
      albumResult.append(collection)
    }
    
    let safeAlbumResult = albumResult
    
    await MainActor.run {
      self.albums = safeAlbumResult.map { Album(name: $0.localizedTitle ?? "-", asset: $0)}
    }
    
    await loadThumbnails()
  }
  
  private func loadThumbnails() async {
    let targetSize = CGSize(width: 300, height: 300)
    
    let assetsFetchOptions = fetchOptions
    assetsFetchOptions.fetchLimit = 1
    
    let requestOptions = PHImageRequestOptions()
    requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isSynchronous = false
    
    for (index, album) in albums.enumerated() {
      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
      fetchOptions.fetchLimit = 1
      
      let fetchResult = PHAsset.fetchAssets(in: album.asset, options: fetchOptions)
      guard let firstAsset = fetchResult.firstObject else { return }
      
      if let image = await requestImageAsync(for: firstAsset, targetSize: targetSize, options: requestOptions) {
        await MainActor.run { self.albums[index].image = image }
      }
    }
  }
  
  private func requestImageAsync(
    for asset: PHAsset,
    targetSize: CGSize,
    options: PHImageRequestOptions
  ) async -> UIImage? {
    await withCheckedContinuation { continuation in
      PHImageManager.default().requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: .aspectFill,
        options: options
      ) { image, _ in
        continuation.resume(returning: image)
      }
    }
  }
  
  func fetchPhotos() {
    guard !isLoading else { return }
    
    self.isLoading = true
    
    defer {
      self.isLoading = false
    }
    
    var fetchResult = PHFetchResult<PHAsset>()
    
    if let album = self.currentAlbum {
      fetchResult = PHAsset.fetchAssets(in: album.asset, options: fetchOptions)
    } else {
      fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    let assets = (0..<fetchResult.count).map { fetchResult.object(at: $0) }
    
    self.assets = assets
  }
  
  func fetchSelectedPhoto(for asset: PHAsset) {
    self.selectedImage = nil
    
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = false
    requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isNetworkAccessAllowed = true
    
    imageManager.requestImage(for: asset,
                              targetSize: PHImageManagerMaximumSize,
                              contentMode: .aspectFill,
                              options: requestOptions) { image, _ in
      if let image = image {
        self.selectedImage = image
      }
    }
  }
  
  func fetchRecentlyPhoto() {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
    fetchOptions.fetchLimit = 1
    
    let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    
    let imageManager = PHCachingImageManager()
    
    if let asset = fetchResult.firstObject{
      let requestOptions = PHImageRequestOptions()
      requestOptions.isSynchronous = false
      requestOptions.deliveryMode = .highQualityFormat
      
      imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
        if let image = image {
          self.images.append(image)
        }
      }
    }
  }
  
  func resetAlbum(_ album: Album?) async {
    self.currentAlbum = album
    self.isLoading = false
    await MainActor.run { self.assets = [] }
  }
  
  func saveImageToPhotos(image: UIImage) async {
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAsset(from: image)
    }, completionHandler: { success, error in
      if success {
        print("Image saved to Photos.")
      } else {
        print("Error saving image: \(String(describing: error))")
      }
    })
  }
}
