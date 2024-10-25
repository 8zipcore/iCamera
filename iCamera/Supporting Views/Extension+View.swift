//
//  Extension+View.swift
//  iCamera
//
//  Created by 홍승아 on 10/23/24.
//

import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        self.opacity(shouldHide ? 0 : 1) // opacity를 통해 뷰를 숨김
    }
}
