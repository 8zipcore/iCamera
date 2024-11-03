//
//  CommentsManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/31/24.
//

import UIKit
import SwiftUI
import Combine

class CommentsManager: ObservableObject{
    var selectedImage = PassthroughSubject<(AlbumManager, Int), Never>()
}
