//
//  FilterManager.swift
//  iCamera
//
//  Created by 홍승아 on 9/30/24.
//

import Foundation
import Combine

enum FilterType{
    case none
    case bloom
}

struct Filter: Hashable{
    var type: FilterType
    var title: String {
        switch type {
        case .none:
            return "none"
        case .bloom:
            return "번짐"
        }
    }
}

class FilterManager: NSObject, ObservableObject {
    var filterSelected = PassthroughSubject<FilterType, Never>()
    
    var cancellables = Set<AnyCancellable>()
    
    func allFilters() -> [Filter] {
        return [
            Filter(type: .none),
            Filter(type: .bloom),
        ]
    }
}
