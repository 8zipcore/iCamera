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
    private let entityName = "ICalendar"
    
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
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
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
                            let image = $0.image == nil ? nil : UIImage(data: $0.image!)
                            let data = CalendarData(id: id, date: date, image: image, comments: comments)
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
        if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context){
            let calendar = NSManagedObject(entity: entity, insertInto: context)
            calendar.setValue(data.id, forKey: "id")
            calendar.setValue(data.date, forKey: "date")
            calendar.setValue(data.comments, forKey: "comments")
            if let image = data.image, let imageData = image.pngData() {
                calendar.setValue(imageData, forKey: "image")
            } else {
                calendar.setValue(nil, forKey: "image")
            }
        }
        saveContext()
    }
    
    func updateData(_ data: CalendarData){
        let fetchRequest: NSFetchRequest<ICalendar> = ICalendar.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", data.id.uuidString)
        do {
            if let calendar = try context.fetch(fetchRequest).first{
                calendar.comments = data.comments
                if let image = data.image, let imageData = image.pngData(){
                    calendar.image = imageData
                }
            }
        } catch {
            print("🌀 불러오기 Error: \(error.localizedDescription)")
        }
        saveContext()
    }
    
    func deleteAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}
