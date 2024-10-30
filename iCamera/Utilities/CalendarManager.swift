//
//  CalendarManager.swift
//  iCamera
//
//  Created by 홍승아 on 10/29/24.
//

import Foundation

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
    var week: [Week] = []
    var days: [String] = []
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())
    private let currentDay = Calendar.current.component(.day, from: Date())
    
    @Published var selectedYear: Int
    @Published var selectedMonth: Int
    @Published var selectedDay: Int
    @Published var weeks: Int
    
    var monthToString: String{
        let monthArray: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return monthArray[selectedMonth - 1]
    }
    
    init(){
        week = Week.allCases.map{ return $0 }
        selectedYear = currentYear
        selectedMonth = currentMonth
        selectedDay = currentDay
        weeks = 5
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
    }
    
    func nextMonth(){
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
        weeks = lastWeek()
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
        guard let startDay = startOfMonth(year: selectedYear, month: selectedMonth),
              let lastDay = daysInMonth(year: selectedYear, month: selectedMonth) else { return "" }
        let daysOfWeek = 7
        let day = (week * daysOfWeek) - (daysOfWeek - day) - startDay + 1
        if day < 1 || day > lastDay{
            return ""
        }
        return "\(day)"
    }
}
