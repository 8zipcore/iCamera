//
//  LUTManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/1/24.
//

import SwiftUI

struct CubeData{
    var demension: Int
    var cubeData: Data
}

class LUTManager{
    static let shared = LUTManager()
    var cubeDataSet: [String : CubeData] = [:]
    let context = CIContext()
    
    func parseCUBEFile(data: Data) -> (Int?, [Float]?) {
        guard let content = String(data: data, encoding: .utf8) else {
            print("데이터를 문자열로 변환할 수 없습니다.")
            return (nil, nil)
        }
        
        let lines = content.split(separator: "\n")
        var lutValues: [Float] = []
        var cubeDimension: Int?

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // LUT 크기 찾기
            if trimmedLine.starts(with: "LUT_3D_SIZE") {
                let components = trimmedLine.split(separator: " ")
                if components.count > 1, let dimension = Int(components[1]) {
                    cubeDimension = dimension
                    continue
                }
            }
            
            // RGB 값 읽기
            let components = trimmedLine.split(separator: " ").compactMap { Float($0) }
            lutValues.append(contentsOf: components)
            
            // RGB 값이 3개인 경우, Alpha 값 추가
            if components.count == 3 {
                lutValues.append(1.0) // Alpha
            }
        }
        
        guard let dimension = cubeDimension else {
            print("LUT 크기를 찾을 수 없습니다.")
            return (nil, nil)
        }
        
        // LUT 데이터 크기 확인
        let expectedSize = dimension * dimension * dimension * 4
        guard lutValues.count == expectedSize else {
            print("LUT 데이터 크기가 잘못되었습니다. 예상 크기: \(expectedSize), 실제 크기: \(lutValues.count)")
            return (nil, nil)
        }
        
        return (cubeDimension, lutValues)
    }
    
    func applyLUTFilter(to inputImage: UIImage, lutFileName: String, intensity: CGFloat) -> CIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        guard let filePath = Bundle.main.path(forResource: lutFileName, ofType: "cube") else {
            print("LUT 파일을 찾을 수 없습니다.")
            return nil
        }
        let lutURL = URL(fileURLWithPath: filePath)
        guard let lutData = try? Data(contentsOf: lutURL) else {
            print("data 변환 error")
            return nil
        }
        
        var cubeData = Data()
        var cubeDimension: Int = 0
        
        if let data = cubeDataSet[lutFileName] {
            cubeData = data.cubeData
            cubeDimension = data.demension
        } else {
            let cubeFileData = parseCUBEFile(data: lutData)
            
            guard let lutValues = cubeFileData.1 else {
                print("parsing error")
                 return nil
            }
            
            cubeData = Data(bytes: lutValues, count: lutValues.count * MemoryLayout<Float>.size)
            cubeDimension = cubeFileData.0!
            
            cubeDataSet[lutFileName] = CubeData(demension: cubeDimension, cubeData: cubeData)
        }
        
        // CIColorCube 필터 생성 및 적용
        let filter = CIFilter.colorCube()
        filter.inputImage = ciImage
        filter.cubeDimension = Float(cubeDimension)
        filter.cubeData = cubeData
        
        guard let filteredImage = filter.outputImage else {
            print("outputImage nil")
            return nil
        }
        
        return filteredImage

        /*
        // 강도 조정: 원본 이미지와 LUT 적용 이미지를 혼합
        
        let mixFilter = CIFilter(name: "CIMix") ?? CIFilter(name: "CIBlendWithAlphaMask")!
        mixFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey) // 원본 이미지
        mixFilter.setValue(filteredImage, forKey: kCIInputImageKey)     // LUT 적용 이미지
        mixFilter.setValue(intensity, forKey: "inputAmount")
        
        guard let outputImage = mixFilter.outputImage else {
            print("outputImage nil after blending")
            return nil
        }
        */
        /*
        if let cgImage = context.createCGImage(outputImage, from: filterImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
         */
    }
}
