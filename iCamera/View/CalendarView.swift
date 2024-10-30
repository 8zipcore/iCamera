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
    
    @StateObject private var topBarViewButtonManager = TopBarViewButtonManager()
    @StateObject private var calendarManager = CalendarManager()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                let viewWidth = geometry.size.width
                let viewHeight = geometry.size.height
                
                VStack{
                    let topBarSize = CGSize(width: viewWidth, height: viewHeight * 0.07)
                    
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
                    let titleViewHeight = viewHeight * 0.07
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
                                    Text("\(calendarManager.selectedYear)")
                                        .font(.system(size: 13))
                                    Spacer()
                                }
                                Text(calendarManager.monthToString)
                                    .font(.system(size: 35))
                                    .padding(.top, 10)
                            }
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
                        .frame(width: viewWidth * 0.95)
                        .position(x: viewWidth / 2, y: titleViewHeight / 2.3)
                    }
                    .frame(height: titleViewHeight)
                    
                    let weekViewHeight = viewHeight * 0.01
                    HStack(spacing: 0){
                        ForEach(calendarManager.week.indices, id: \.self){ index in
                            let cellWidth: CGFloat = viewWidth / CGFloat(7)
                            let xPosition: CGFloat = cellWidth / 2
                            let weekToString = calendarManager.week[index].rawValue
                            Text(weekToString)
                                .font(.system(size: 13))
                                .frame(width: cellWidth)
                                .position(x: xPosition, y: weekViewHeight / 2)
                        }
                    }
                    .frame(height: weekViewHeight)
                    VStack(spacing: 0){
                        let cellWidth: CGFloat = viewWidth / 7
                        let cellHeight: CGFloat = cellWidth * 4.5 / 3
                        ForEach(1...calendarManager.weeks, id: \.self){ week in
                            HStack(spacing: 0){
                                ForEach(1...7, id: \.self){ day in
                                    let dayToString = calendarManager.dayToString(week: week, day: day)
                                    CalendarCellView(day: dayToString, image: nil, hiddenBottomLine: week != calendarManager.weeks)
                                        .frame(width: cellWidth, height: cellHeight)
                                }
                            }
                        }
                        
                        ZStack{
                            GradientRectangleView()
                            VStack{
                                HStack{
                                    Image("pink_circle")
                                        .resizable()
                                        .frame(width: viewWidth * 0.03, height: viewWidth * 0.03)
                                    Text("Agust 24th's comment")
                                        .font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                }
                                .padding([.leading, .trailing], 10)
                                Text("nothing . . .")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 10)
                                    .font(.system(size: 13))
                                Spacer()
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarHidden(true)
    }
}

@available(iOS 16.0, *)
#Preview {
    CalendarView(navigationPath: .constant(NavigationPath()))
}
