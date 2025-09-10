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

final class FilterManager: NSObject, ObservableObject {
  var filterSelected = PassthroughSubject<FilterType, Never>()
  
  @Published var filterValue: CGFloat = .zero
  @Published var selectedFilter: Filter = Filter(type: .none)
  
  private let context = CIContext()
  
  // NSCache 사용 → 메모리 부족 시 자동 삭제
  private let filterImageCache = NSCache<NSString, UIImage>()
  
  var cancellables = Set<AnyCancellable>()
  
  var isSelectedFilter: Bool { selectedFilter.type != .none }
  
  var filters: [Filter] {
    [
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
  
  func setFilter(_ filter: Filter) {
    selectedFilter = filter
    filterValue = 0.5
  }
  
  func isSameFilter(_ filter: Filter) -> Bool {
    selectedFilter == filter
  }
  
  func setFilterValue(_ value: CGFloat) {
    filterValue = value
  }
  
  func previewFilterImage(filter: Filter) -> UIImage? {
    UIImage(named: "filter_\(filter.title)")
  }
  
  // MARK: - 필터 적용 + 캐시
  func filterImage(image: UIImage, targetSize: CGSize? = nil) -> UIImage? {
    let cacheKey = "\(selectedFilter.type)_\(targetSize?.width ?? 0)x\(targetSize?.height ?? 0)" as NSString
    
    if let cached = filterImageCache.object(forKey: cacheKey) {
      return cached
    }
    
    guard let filtered = applyFilters(to: image, targetSize: targetSize) else { return nil }
    
    filterImageCache.setObject(filtered, forKey: cacheKey)
    return filtered
  }
  
  func applyFilters(filter: Filter, image: UIImage, targetSize: CGSize? = nil) -> UIImage? {
    selectedFilter = filter
    return applyFilters(to: image, targetSize: targetSize)
  }
  
  func applyFilters(to image: UIImage, targetSize: CGSize? = nil) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    var outputImage: CIImage?
    
    switch selectedFilter.type {
    case .none:
      outputImage = ciImage
    case .bloom:
      let bloomFilter = CIFilter.bloom()
      bloomFilter.inputImage = ciImage
      // bloomFilter.intensity = Float(filterValue)
      outputImage = bloomFilter.outputImage
    default:
      guard let filtered = LUTManager.shared.applyLUTFilter(
        to: image,
        lutFileName: selectedFilter.fileName,
        intensity: filterValue
      ) else { return nil }
      outputImage = filtered
    }
    
    guard let outputImage = outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
    
    var resultImage = UIImage(cgImage: cgImage)
    
    // targetSize가 있으면 리사이즈
    if let targetSize = targetSize {
      let renderer = UIGraphicsImageRenderer(size: targetSize)
      resultImage = renderer.image { _ in
        resultImage.draw(in: CGRect(origin: .zero, size: targetSize))
      }
    }
    
    return resultImage
  }
  
  func resetFilterImageCache() {
    filterImageCache.removeAllObjects()
  }
}
