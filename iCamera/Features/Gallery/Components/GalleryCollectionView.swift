//
//  GalleryCollectionView.swift
//  iCamera
//
//  Created by 홍승아 on 12/19/24.
//

import SwiftUI
import Photos

struct GalleryCollectionView: UIViewRepresentable {
  @Binding var assets: [PHAsset]
  var itemSize: CGSize
  var spacing: CGFloat
  var onTap: (PHAsset) -> Void
  
  func makeUIView(context: Context) -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: itemSize.width, height: itemSize.width)
    layout.minimumLineSpacing = spacing
    layout.minimumInteritemSpacing = spacing
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.contentInset = .zero
    collectionView.scrollIndicatorInsets = .zero
    collectionView.delegate = context.coordinator
    collectionView.dataSource = context.coordinator
    collectionView.prefetchDataSource = context.coordinator
    collectionView.register(GalleryImageViewCell.self, forCellWithReuseIdentifier: GalleryImageViewCell.identifier)
    return collectionView
  }
  
  func updateUIView(_ uiView: UICollectionView, context: Context) {
    let oldAssets = context.coordinator.assets
    if oldAssets != assets {
      context.coordinator.assets = assets
      uiView.reloadData()
    }
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }
  
  class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    var parent: GalleryCollectionView
    let imageManager = PHCachingImageManager()
    var assets: [PHAsset] = []
    
    init(parent: GalleryCollectionView) {
      self.parent = parent
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return parent.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      let asset = parent.assets[indexPath.item]
      parent.onTap(asset)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryImageViewCell.identifier, for: indexPath) as? GalleryImageViewCell else { return UICollectionViewCell() }
      let asset = parent.assets[indexPath.item]
      cell.configureView(asset: asset, targetSize: parent.itemSize)
      return cell
    }
    
    // MARK: - Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
      let assetsToPrefetch = indexPaths.map { parent.assets[$0.item] }
      let options = PHImageRequestOptions()
      options.deliveryMode = .opportunistic
      imageManager.startCachingImages(for: assetsToPrefetch, targetSize: parent.itemSize, contentMode: .aspectFill, options: options)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
      let assetsToCancel = indexPaths.map { parent.assets[$0.item] }
      imageManager.stopCachingImages(for: assetsToCancel, targetSize: parent.itemSize, contentMode: .aspectFill, options: nil)
    }
  }
}

class GalleryImageViewCell: UICollectionViewCell {
  static let identifier = "GalleryImageViewCell"
  
  private let imageManager = PHCachingImageManager()
  private let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    imageView.frame = contentView.bounds
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    backgroundColor = .lightGray
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func configureView(asset: PHAsset?, targetSize: CGSize) {
    imageView.image = nil
    guard let asset = asset else { return }
    
    let options = PHImageRequestOptions()
    options.deliveryMode = .opportunistic
    
    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] image, _ in
      Task { @MainActor in
        self?.imageView.image = image
      }
    }
  }
}
