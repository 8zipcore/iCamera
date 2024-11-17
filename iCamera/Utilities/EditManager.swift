//
//  EditManager.swift
//  iCamera
//
//  Created by 홍승아 on 11/16/24.
//

import Foundation
import Combine

class EditManager: ObservableObject{
    var selectText = PassthroughSubject<Void, Never>()
    var selectSticker = PassthroughSubject<Void, Never>()
}
