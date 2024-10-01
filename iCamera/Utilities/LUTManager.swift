//
//  LUTManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/1/24.
//

import SwiftUI

class LUTManager{
    func parseCUBEFile(data: Data) -> [Float]? {
        guard let content = String(data: data, encoding: .utf8) else {
            print("데이터를 문자열로 변환할 수 없습니다.")
            return nil
        }
        
        let lines = content.split(separator: "\n")
        var lutValues = [Float]()
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
            return nil
        }
        
        // LUT 데이터 크기 확인
        let expectedSize = dimension * dimension * dimension * 4
        guard lutValues.count == expectedSize else {
            print("LUT 데이터 크기가 잘못되었습니다. 예상 크기: \(expectedSize), 실제 크기: \(lutValues.count)")
            return nil
        }
        
        return lutValues
    }
    
    func applyLUTFilter(to inputImage: UIImage, lutFileName: String, lutFileType: String, size: Int) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        // Asset 번들에서 파일 URL 찾기
        let filePath = "/Users/sainkr/Desktop/iCamera/cube/test.CUBE"
        let lutURL = URL(fileURLWithPath: filePath)
        guard let lutData = try? Data(contentsOf: lutURL) else {
            print("LUT 파일을 찾을 수 없습니다.")
            return nil
        }
        
        guard let lutData = parseCUBEFile(data: lutData) else {
            print("parsing error")
             return nil
        }
        
        let cubeData =  Data(bytes: lutData, count: lutData.count * MemoryLayout<Float>.size)

        // CIColorCube 필터 생성 및 적용
        let filter = CIFilter.colorCube()
        filter.inputImage = ciImage
        filter.cubeDimension = 32
        filter.cubeData = cubeData
        
        guard let outputImage = filter.outputImage else {
            print("outputImage nil")
            return nil
        }
        
        let context = CIContext()
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}
