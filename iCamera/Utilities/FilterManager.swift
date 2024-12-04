//
//  FilterManager.swift
//  iCamera
//
//  Created by 홍승아 on 9/30/24.
//

import UIKit
import Combine

enum FilterType{
    case none
    case bloom
    case fuji
    case nikon1
    case nikon2
    case nikon3
    case sony1
    case sony2
    case cinema
    case daily
}

struct Filter: Hashable, Equatable{
    var type: FilterType
    var title: String {
        switch type {
        case .none:
            return "none"
        case .bloom:
            return "blur"
        case .fuji:
            return "fuji"
        case .nikon1:
            return "nikon1"
        case .nikon2:
            return "nikon2"
        case .nikon3:
            return "nikon3"
        case .sony1:
            return "sony1"
        case .sony2:
            return "sony2"
        case .cinema:
            return "cinema"
        case .daily:
            return "daily"
        }
    }
    var fileName: String {
        switch type {
        case .none:
            return "-"
        case .bloom:
            return "-"
        case .fuji:
            return "XT4_FLog_FGamut_to_WDR_BT.709_33grid_V.1.01"
        case .nikon1:
            return "RED_FilmBias_Rec2020_N-Log_to_Rec709_BT1886"
        case .nikon2:
            return "RED_FilmBiasOffset_Rec2020_N-Log_to_Rec709_BT1886"
        case .nikon3:
            return "RED_Achromic_Rec2020_N-Log_to_Rec709_BT1886"
        case .sony1:
            return "From_SLog2SGumut_To_SLog2-709_"
        case .sony2:
            return "SLog3SGamut3.CineToSLog2-709"
        case .cinema:
            return "FB LUT-Cinematic1"
        case .daily:
            return "FB Basic Daily"
        }
    }
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return lhs.type == rhs.type
    }
}

class FilterManager: NSObject, ObservableObject {
    var filterSelected = PassthroughSubject<FilterType, Never>()
    
    @Published var filterValue: CGFloat = .zero
    @Published var selectedFilter: Filter = Filter(type: .none)
    
    var cancellables = Set<AnyCancellable>()
    
    func allFilters() -> [Filter] {
        return [
            Filter(type: .none),
            Filter(type: .bloom),
            Filter(type: .fuji),
            Filter(type: .nikon1),
            Filter(type: .nikon2),
            Filter(type: .nikon3),
            Filter(type: .sony1),
            Filter(type: .sony2),
            Filter(type: .cinema),
            Filter(type: .daily)
        ]
    }
    
    func setFilter(_ filter: Filter){
        selectedFilter = filter
        filterValue = 0.5
    }
    
    func isSameFilter(_ filter: Filter) -> Bool{
        return selectedFilter == filter
    }
    
    func setFilterValue(_ value: CGFloat){
        filterValue = value
    }
    
    func previewFilterImage(filter: Filter) -> UIImage?{
        return UIImage(named: "filter_\(filter.title)")
    }
    
    func applyFilters(filter: Filter, image: UIImage) -> UIImage?{
        selectedFilter = filter
        return applyFilters(to: image)
    }
    
    func applyFilters(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let scaleFactor: CGFloat = 0.5 // 절반 크기로 다운스케일
        let scaledSize = CGSize(width: ciImage.extent.width * scaleFactor, height: ciImage.extent.height * scaleFactor)

        let resizedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        let filterValue = filterValue
        let filter = selectedFilter
        
        let context = CIContext()
        var outputImage: CIImage?
        
        switch filter.type {
        case .none:
            outputImage = resizedImage
        case .bloom:
            let bloomFilter = CIFilter.bloom()
            bloomFilter.inputImage = resizedImage
            bloomFilter.intensity = Float(filterValue)
            outputImage = bloomFilter.outputImage
        default:
            guard let filteredImage = LUTManager.shared.applyLUTFilter(to: image, lutFileName: filter.fileName, intensity: filterValue) else { return nil }
            
            return filteredImage
        }
        
        guard let outputImage = outputImage else { return nil}
        
        let finalImage = outputImage.transformed(by: CGAffineTransform(scaleX: 1/scaleFactor, y: 1/scaleFactor))
        
        // CIContext를 통해 최종 이미지 생성
        if let cgImage = context.createCGImage(finalImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
}
