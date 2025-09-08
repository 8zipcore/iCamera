//
//  GalleryCollectionView.swift
//  iCamera
//
//  Created by 홍승아 on 12/19/24.
//

import SwiftUI
import Photos

struct GalleryCollectionView: UIViewRepresentable {
    @ObservedObject var albumManager: AlbumManager
    var itemSize: CGSize
    var spacing: CGFloat
    var onTap: (PHAsset) -> Void
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize.width, height: itemSize.width)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        collectionView.register(GalleryImageViewCell.self, forCellWithReuseIdentifier: GalleryImageViewCell.identifier)
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(albumManager: albumManager, itemSize: itemSize, onTap: onTap)
    }

    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        @ObservedObject var albumManager: AlbumManager
        var itemSize: CGSize
        var onTap: (PHAsset) -> Void

        init(albumManager: AlbumManager, itemSize: CGSize, onTap: @escaping (PHAsset) -> Void) {
            self.albumManager = albumManager
            self.itemSize = itemSize
            self.onTap = onTap
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return albumManager.assets.count
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let asset = albumManager.assets[indexPath.item]{
                onTap(asset)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryImageViewCell.identifier, for: indexPath) as! GalleryImageViewCell
            
            cell.configureView(asset: albumManager.assets[indexPath.item], targetSize: itemSize)
            
            return cell
        }
    }
}

class GalleryImageViewCell: UICollectionViewCell {
    static let identifier = "GalleryImageViewCell"
    let imageManager = PHCachingImageManager()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func configureView(asset: PHAsset?, targetSize: CGSize){
        imageView.image = nil
        
        if let asset = asset{
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
