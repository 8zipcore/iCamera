//
//  EditFilterView.swift
//  iCamera
//
//  Created by 홍승아 on 11/27/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct EditFilterView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject var filterManager: FilterManager
    @StateObject var customSliderManager = CustomSliderManager()
    
    var body: some View {
        GeometryReader{ geometry in
            let viewWidth = geometry.size.width
            VStack{
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 0){
                        let cellWidth = viewWidth * 0.17
                        ForEach(filterManager.allFilters(), id:\.self){ filter in
                            FilterTypeCell(filter: filter)
                                .frame(width: cellWidth, height: cellWidth)
                                .onTapGesture {
                                    if filterManager.isSameFilter(filter) == false {
                                        filterManager.setFilter(filter)
                                    }
                                }
                        }
                    }
                }
                if filterManager.selectedFilter.type != .none {
                    let filterValue = filterManager.filterValue
                    
                    let minFilterValue: CGFloat = 0.3
                    let maxFilterValue: CGFloat = 1
                    let percentage = (filterValue - minFilterValue) / (maxFilterValue - minFilterValue)
                    
                    CustomSlider(value: percentage, customSliderManager: customSliderManager)
                        .frame(width: viewWidth * 0.9, height: 30)
                        .padding(.top, 15)
                        .onReceive(customSliderManager.onChange){ value in
                            let adjustedValue = minFilterValue + (value * (maxFilterValue - minFilterValue))
                            filterManager.setFilterValue(adjustedValue)
                        }
                }
            }
            .background(.clear)
            .padding(.top, 30)
        }
    }
}
