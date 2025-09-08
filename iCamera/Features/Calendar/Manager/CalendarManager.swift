//
//  CalendarManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/29/24.
//

import UIKit
import Combine
import Photos

enum Week: String, CaseIterable{
    case sun = "Sun"
    case mon = "Mon"
    case tue = "Tue"
    case wed = "Wed"
    case thu = "Thu"
    case fri = "Fri"
    case sat = "Sat"
}

class CalendarManager: ObservableObject{
    static let shared = CalendarManager()
    
    var week: [Week] = []
    var days: [String] = []
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())
    private let currentDay = Calendar.current.component(.day, from: Date())
    
    @Published var selectedYear: Int
    @Published var selectedMonth: Int
    @Published var selectedDay: Int
    @Published var weeks: Int
    @Published var dateComment: String = ""
    
    private let monthArray: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var monthToString: String{
        return monthArray[selectedMonth - 1]
    }
    
    var selectedImage = PassthroughSubject<(AlbumManager, PHAsset), Never>()
    @Published var calendarDataArray: [CalendarData] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        week = Week.allCases.map{ return $0 }
        selectedYear = currentYear
        selectedMonth = currentMonth
        selectedDay = currentDay
        weeks = 5
    }
    
    func todayDate(){
        selectedYear = currentYear
        selectedMonth = currentMonth
        selectedDay = currentDay
        
        dateComment = dateCommentToString()
    }
    
    func daysInMonth(year: Int, month: Int) -> Int? {
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(year: year, month: month)
        
        guard let date = calendar.date(from: dateComponents) else {
            return nil // 유효하지 않은 날짜일 경우 nil 반환
        }
        
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count
    }
    
    func lastWeek() -> Int{
        guard let startDay = startOfMonth(year: selectedYear, month: selectedMonth),
              let lastDay = daysInMonth(year: selectedYear, month: selectedMonth) else { return 5 }
        let daysOfWeek = 7
        let weeks = (startDay - 1 + lastDay) / daysOfWeek
        if weeks > 4 && (startDay - 1 + lastDay) % daysOfWeek == 0 {
            return weeks
        }
        return weeks + 1
    }
    
    func previousMonth(){
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
        weeks = lastWeek()
        selectedDay = 0
    }
    
    func nextMonth(){
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
        weeks = lastWeek()
        selectedDay = 0
    }
    
    func startOfMonth(year: Int, month: Int) -> Int?{
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1 // 1일로 설정
        
        guard let date = calendar.date(from: dateComponents) else {
            return nil // 유효하지 않은 날짜일 경우 nil 반환
        }
        
        let weekday = calendar.component(.weekday, from: date)
        
        return weekday
    }
    
    func dayToString(week: Int, day: Int) -> String{
        let day = dayOfMonth(week: week, day: day)
        if day < 0 {
            return ""
        }
        return "\(day)"
    }
    
    func dayOfMonth(week: Int, day: Int) -> Int {
        guard let startDay = startOfMonth(year: selectedYear, month: selectedMonth),
              let lastDay = daysInMonth(year: selectedYear, month: selectedMonth) else { return -1 }
        let daysOfWeek = 7
        let day = (week * daysOfWeek) - (daysOfWeek - day) - startDay + 1
        if day < 1 || day > lastDay{
            return -1
        }
        return day
    }
    
    func yearToString() -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // 기본 숫자 스타일 설정
        if let formattedString = formatter.string(from: NSNumber(value: selectedYear)) {
            return formattedString.replacingOccurrences(of: ",", with: "")
        }
        return ""
    }
    
    func dateCommentToString() -> String {
        var day: String = ""
        switch selectedDay{
        case 1:
            day = "1st"
        case 2:
            day = "2nd"
        case 3:
            day = "3rd"
        default:
            day = "\(selectedDay)th"
        }
        return "\(monthArray[selectedMonth - 1]) \(day)'s comment"
    }
    
    func createDate(year: Int, month: Int, day: Int) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // UTC 기준
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        return calendar.date(from: dateComponents)
    }
    
    func selectedDate() -> Date?{
        return createDate(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
    
    func selectedCommnets() -> String{
        let nothingComments = "noting . . ."
        if let index = calendarDataArrayIndex() {
            if calendarDataArray[index].comments.count == 0 {
                return nothingComments
            }
            return calendarDataArray[index].comments
        }
        return nothingComments
    }
}
// CalendarData
extension CalendarManager{
    func calendarDataArrayIndex(week: Int, day: Int) -> Int?{
        if let date = createDate(year: selectedYear, month: selectedMonth, day: dayOfMonth(week: week, day: day)){
            for index in calendarDataArray.indices{
                if date == calendarDataArray[index].date{
                    return index
                }
            }
        }
        return nil
    }
    
    func calendarDataArrayIndex() -> Int?{
        if let selectedDate = createDate(year: selectedYear, month: selectedMonth, day: selectedDay){
            for index in calendarDataArray.indices{
                let date = calendarDataArray[index].date
                if Calendar.current.isDate(selectedDate, inSameDayAs: date){
                    return index
                }
            }
        }
        return nil
    }
    
    func updateData(_ calendarData: CalendarData){
        if calendarDataArray.filter({ $0.id == calendarData.id }).count == 0 {
            CoreDataManager.shared.saveData(calendarData)
            calendarDataArray.append(calendarData)
        } else if let index = calendarDataArrayIndex() {
            if calendarData.image == nil && calendarData.comments.count == 0 {
                CoreDataManager.shared.deleteData(calendarData)
                calendarDataArray.remove(at: index)
            } else {
                CoreDataManager.shared.updateData(calendarData)
                calendarDataArray[index] = calendarData
            }
        }
    }
    
    func fetchData(){
        CoreDataManager.shared.fetchData()
            .sink(receiveCompletion: { completion in
                  switch completion{
                  case .finished:
                      print("finish")
                  case .failure(_):
                      print("fail")
                  }
              }, receiveValue: { value in
                  self.calendarDataArray = value
              })
              .store(in: &cancellables)
    }
    
    func getWeekdays() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        return daysOfWeek[weekday - 1]
    }
    
    func getMonthAndYear() -> String {
        let monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return "\(monthArray[currentMonth - 1]) \(currentYear)"
    }
}
