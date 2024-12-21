//
//  CalendarView.swift
//  iCamera
//
//  Created by 홍승아 on 10/25/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct CalendarView: View {
    @Binding var navigationPath: NavigationPath
    
    @StateObject var calendarManager: CalendarManager
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                VStack(spacing: 0){
                    let topBarSize = topBarViewButtonManager.topBarViewSize(viewWidth: viewWidth)
                    
                    ZStack{
                        TopBarView(title: "Calendar",
                                   imageSize: topBarSize,
                                   isTrailingButtonHidden: false,
                                   buttonManager: topBarViewButtonManager)
                        .frame(width: topBarSize.width, height: topBarSize.height)
                        .onReceive(topBarViewButtonManager.buttonClicked){ buttonType in
                            if buttonType == .home {
                                dismiss()
                            }
                        }
                        HStack{
                            Button(action:{
                                calendarManager.todayDate()
                            }){
                                let imageWidth: CGFloat = viewWidth * 0.17
                                let imageHeight: CGFloat = imageWidth * 54 / 119
                                ZStack{
                                    Image("blue_button")
                                        .resizable()
                                        .frame(width: imageWidth, height: imageHeight)
                                    Text("Today")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 12)
                    }
                    Spacer()
                    let titleViewWidth = viewWidth * 0.95
                    let titleViewHeight = viewWidth * 172 / 1123
                    ZStack{
                        GradientRectangleView()
                        HStack{
                            let buttonWidth: CGFloat = viewWidth * 0.045
                            let buttonHeight: CGFloat = buttonWidth * 8 / 7
                            Button(action:{
                                calendarManager.previousMonth()
                            }){
                                Image("month_button")
                                    .resizable()
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }
                            Spacer()
                            ZStack{
                                VStack{
                                    Text(calendarManager.yearToString())
                                        .font(.system(size: 13))
                                        .foregroundStyle(.black)
                                    Spacer()
                                }
                                .padding(.top, 10)
                                Text(calendarManager.monthToString)
                                    .font(.system(size: 35))
                                    .foregroundStyle(.black)
                                    .padding(.top, 20)
                            }
                            .padding(.bottom, 10)
                            Spacer()
                            Button(action:{
                                calendarManager.nextMonth()
                            }){
                                Image("month_button")
                                    .resizable()
                                    .rotationEffect(.degrees(180))
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }
                        }
                        .frame(width: titleViewWidth)
                    }
                    .frame(width: viewWidth, height: titleViewHeight)
                    
                    let weekViewHeight = viewWidth * 88 / 1125
                    HStack(spacing: 0){
                        ForEach(calendarManager.week.indices, id: \.self){ index in
                            let cellWidth: CGFloat = viewWidth / CGFloat(7)
                            let xPosition: CGFloat = cellWidth / 2
                            let weekToString = calendarManager.week[index].rawValue
                            Text(weekToString)
                                .font(.system(size: 13))
                                .foregroundStyle(.black)
                                .frame(width: cellWidth)
                                .position(x: xPosition, y: weekViewHeight / 2)
                        }
                    }
                    .frame(height: weekViewHeight)
                    .background(.white)
                    VStack(spacing: 0){
                        let cellWidth: CGFloat = viewWidth / 7
                        let cellHeight: CGFloat = cellWidth * 4.5 / 3
                        ForEach(1...calendarManager.weeks, id: \.self){ week in
                            HStack(spacing: 0){
                                ForEach(1...7, id: \.self){ day in
                                    let dayToString = calendarManager.dayToString(week: week, day: day)
                                    let index = calendarManager.calendarDataArrayIndex(week: week, day: day)
                                    CalendarCell(day: dayToString,
                                                     image: index == nil ? nil : calendarManager.calendarDataArray[index!].image,
                                                     hiddenBottomLine: week != calendarManager.weeks)
                                        .frame(width: cellWidth, height: cellHeight)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let selectedDay = calendarManager.dayOfMonth(week: week, day: day)
                                            if selectedDay > 0 {
                                                calendarManager.selectedDay = selectedDay
                                                calendarManager.dateComment = calendarManager.dateCommentToString()
                                            }
                                        }
                                }
                            }
                        }
                        
                        ZStack{
                            GradientRectangleView()
                            if calendarManager.selectedDay > 0{
                                VStack{
                                    HStack{
                                        Image("pink_circle")
                                            .resizable()
                                            .frame(width: viewWidth * 0.03, height: viewWidth * 0.03)
                                        Text(calendarManager.dateComment)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.black)
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing], 10)
                                    Text(calendarManager.selectedCommnets())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding([.leading, .trailing], 10)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.black)
                                    Spacer()
                                    HStack{
                                        Spacer()
                                        NavigationLink(destination: CommentsView(navigationPath: $navigationPath, calendarManager: calendarManager, viewType: .calendar)){
                                            let imageWidth: CGFloat = viewWidth * 0.2
                                            let imageHeight: CGFloat = imageWidth * 101 / 238
                                            ZStack{
                                                Image("blue_button")
                                                    .resizable()
                                                    .frame(width: imageWidth, height: imageHeight)
                                                Text("Details")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                    .frame(width: viewWidth * 0.85)
                                    .padding(.bottom, 30)
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                }
                .background(.white)
                .ignoresSafeArea(edges: .bottom)
                .onAppear{
                    print("Calendar", viewHeight)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
