//
//  StoredStickerManager.swift
//  iCamera
//
//  Created by 홍승아 on 11/16/24.
//

import SwiftUI
import Combine

class StoredStickerManager: ObservableObject{
    
    @Published var stickerArray: [StickerData] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func addSticker(_ sticker: StickerData){
        stickerArray.append(sticker)
        print("Add")
        CoreDataManager.shared.saveData(sticker)
    }
    
    func deleteSticker(index: Int){
        let sticker = stickerArray[index]
        if let index = stickerArray.firstIndex(where: {$0.id == sticker.id}){
            stickerArray.remove(at: index)
            print("delete")
            CoreDataManager.shared.deleteData(sticker)
        }
    }
    
    func fetchStickers(){
        CoreDataManager.shared.fetchStickerData()
            .sink(receiveCompletion: { completion in
                switch completion{
                case .finished:
                    print("✅ StickerData 불러오기 완료")
                case .failure(let error):
                    print("🌀 error : \(error)")
                }
            }, receiveValue: { stickerArray in
                self.stickerArray = stickerArray
            })
            .store(in: &cancellables)
    }
}
