//
//  CoreDataManager.swift
//  iCamera
//
//  Created by 홍승아 on 11/5/24.
//

import UIKit
import CoreData
import Combine

class CoreDataManager{
    static let shared = CoreDataManager()
    
    private let containerName = "iCamera"
    private let calendarEntity = "ICalendar"
    private let stickerEntity = "ISticker"
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func saveContext(){
        if context.hasChanges{
            do{
                try context.save()
                print("✅ 저장")
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
/* CalendarData */
extension CoreDataManager{
    func fetchData() -> AnyPublisher<[CalendarData], Error> {
        Future { [context] promise in
            context.perform {
                let request: NSFetchRequest<ICalendar> = ICalendar.fetchRequest()
                do{
                    let calendarArray = try context.fetch(request)
                    var calendarDataArray: [CalendarData] = []
                    print("✅ 저장 데이터  - - - -")
                    calendarArray.forEach{
                        if let id = $0.id, let date = $0.date, let comments = $0.comments{
                            let data = CalendarData(id: id, date: date, image: $0.image, comments: comments)
                            calendarDataArray.append(data)
                            print(data)
                        }
                    }
                    print("- - - - - - - - - -")
                    promise(.success(calendarDataArray))
                } catch{
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
    func saveData(_ data: CalendarData){
        if let entity = NSEntityDescription.entity(forEntityName: calendarEntity, in: context){
            let calendar = NSManagedObject(entity: entity, insertInto: context)
            calendar.setValue(data.id, forKey: "id")
            calendar.setValue(data.date, forKey: "date")
            calendar.setValue(data.comments, forKey: "comments")
            calendar.setValue(data.image, forKey: "image")
            saveContext()
        }
    }
    
    func updateData(_ data: CalendarData){
        let fetchRequest: NSFetchRequest<ICalendar> = ICalendar.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", data.id.uuidString)
        do {
            if let calendar = try context.fetch(fetchRequest).first{
                calendar.comments = data.comments
                calendar.image = data.image
                
                saveContext()
            }
        } catch {
            print("🌀 Update Error: \(error.localizedDescription)")
        }
    }
    
    func deleteData(_ data: CalendarData){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: calendarEntity)
         fetchRequest.predicate = NSPredicate(format: "id == %@", data.id.uuidString)
         do {
             if let object = try context.fetch(fetchRequest).first as? NSManagedObject{
                 context.delete(object)
             }
             saveContext()
         } catch {
             print("🌀 Delete Error: \(error)")
         }
    }
    
    func deleteAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: calendarEntity)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}
/* Sticker Data */
extension CoreDataManager{
    func fetchStickerData() -> AnyPublisher<[StickerData], Error> {
        Future { [context] promise in
            context.perform {
                let request: NSFetchRequest<ISticker> = ISticker.fetchRequest()
                do{
                    let stickerArray = try context.fetch(request)
                    var stickerDataArray: [StickerData] = []
                    stickerArray.forEach{
                        if let id = $0.id, let image = $0.image == nil ? nil : UIImage(data: $0.image!){
                            let data = StickerData(id: id, image: image)
                            stickerDataArray.append(data)
                        }
                    }
                    promise(.success(stickerDataArray))
                } catch{
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveData(_ data: StickerData){
        if let entity = NSEntityDescription.entity(forEntityName: stickerEntity, in: context){
            let sticker = NSManagedObject(entity: entity, insertInto: context)
            sticker.setValue(data.id, forKey: "id")
            let imageData = data.image.pngData()
            sticker.setValue(imageData, forKey: "image")
            
            saveContext()
        }
    }
    
    func deleteData(_ data: StickerData){
        let fetchRequest: NSFetchRequest<ISticker> = ISticker.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", data.id.uuidString)
        do {
            if let sticker = try context.fetch(fetchRequest).first{
                context.delete(sticker)
                
                saveContext()
            }
        } catch {
            print("🌀 불러오기 Error: \(error.localizedDescription)")
        }
    }
}
