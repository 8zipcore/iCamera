//
//  AlbumError.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/25.
//

import UIKit
import Photos

enum AlbumError: Error {
  case loading
}

struct Album: Identifiable, Hashable {
  var id = UUID()
  var image: UIImage?
  var name: String
  var asset: PHAssetCollection
}
