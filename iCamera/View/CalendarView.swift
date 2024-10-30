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
                    
                    ZStack{
                        GradientRectangleView()
                        HStack{
                            let buttonWidth: CGFloat = viewWidth * 0.055
                            let buttonHeight: CGFloat = buttonWidth * 8 / 7
                            Button(action:{
                                calendarManager.previousMonth()
                            }){
                                Image("month_button")
                                    .resizable()
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.leading, 20)
                            Spacer()
                            ZStack{
                                VStack{
                                    Text("\(calendarManager.selectedYear)")
                                        .font(Font(UIFont.systemFont(ofSize: 13, weight: .medium)))
                                    Spacer()
                                }
                                Text(calendarManager.monthToString)
                                    .font(Font(UIFont.systemFont(ofSize: 33, weight: .medium)))
                                    .padding(.top, 3)
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
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 20)
                        }
                    }
                    .frame(height: viewHeight * 0.07)
                    
                    HStack{
                        ForEach(calendarManager.week.indices, id: \.self){ index in
                            let weekToString = calendarManager.week[index].rawValue
                            Text(weekToString)
                            if index < calendarManager.week.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding([.leading, .trailing], 10)
                    VStack(spacing: 0){
                        let cellWidth: CGFloat = viewWidth / 7
                        let cellHeight: CGFloat = cellWidth * 4.5 / 3
                        ForEach(1...5, id: \.self){ week in
                            HStack(spacing: 0){
                                ForEach(1...7, id: \.self){ day in
                                    let dayToString = calendarManager.dayToString(week: week, day: day)
                                    CalendarCellView(day: dayToString, image: nil, hiddenBottomLine: week != 5)
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
                                        .font(Font(UIFont.systemFont(ofSize: 15, weight: .medium)))
                                    Spacer()
                                }
                                .padding([.leading, .trailing], 10)
                                Text("nothing . . .")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 10)
                                    .font(Font(UIFont.systemFont(ofSize: 13, weight: .medium)))
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
