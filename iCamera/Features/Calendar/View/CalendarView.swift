//
//  CalendarView.swift
//  iCamera
//
//  Created by 홍승아 on 10/25/24.
//

import SwiftUI

struct CalendarView: View {
  
  enum NavigationDestination {
    case comments
  }
  
  @Environment(\.dismiss) var dismiss
  
  @Binding var navigationPath: NavigationPath
  @StateObject var calendarManager: CalendarManager

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        titleSection(containerSize: geometry.size)
        
        weekdayTitleSection(containerSize: geometry.size)
        
        calendarSection(containerSize: geometry.size)
      }
      .background(.white)
      .ignoresSafeArea(edges: .bottom)
      .navigationBar(
        .calendar,
        leadingButtonType: .today,
        onLeadingButtonTap: {
          calendarManager.todayDate()
        },
        trailingButtonType: .home,
        onTrailingButtonTap: {
          dismiss()
        }
      )
      .navigationDestination(for: NavigationDestination.self) { destination in
        switch destination {
        case .comments:
          CommentsView(
            navigationPath: $navigationPath,
            calendarManager: calendarManager,
            viewType: .calendar
          )
        }
      }
    }
  }
}

// MARK: - Subviews
extension CalendarView {
  @ViewBuilder
  private func titleSection(containerSize: CGSize) -> some View {
    let titleViewHeight = containerSize.width * 172 / 1123
    
    HStack {
      let buttonWidth: CGFloat = containerSize.width * 0.045
      let buttonHeight: CGFloat = buttonWidth * 8 / 7
      
      Button {
        calendarManager.previousMonth()
      } label: {
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
      
      Button {
        calendarManager.nextMonth()
      } label: {
        Image("month_button")
          .resizable()
          .rotationEffect(.degrees(180))
          .frame(width: buttonWidth, height: buttonHeight)
      }
    }
    .padding(.horizontal, .mediumPadding)
    .frame(width: containerSize.width, height: titleViewHeight)
    .background(
      Rectangle()
        .fill(
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .white, location: 0.07),
              .init(color: Colors.silver, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
          )
        )
      )
  }
  
  @ViewBuilder
  private func weekdayTitleSection(containerSize: CGSize) -> some View {
    let weekViewHeight = containerSize.width * 88 / 1125
    
    HStack(spacing: 0) {
      ForEach(calendarManager.week.indices, id: \.self){ index in
        let cellWidth: CGFloat = containerSize.width / CGFloat(7)
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
  }
  
  private func calendarSection(containerSize: CGSize) -> some View {
    VStack(spacing: 0) {
      let cellWidth: CGFloat = containerSize.width / 7
      let cellHeight: CGFloat = cellWidth * 4.5 / 3
      
      ForEach(1...calendarManager.weeks, id: \.self) { week in
        HStack(spacing: 0) {
          ForEach(1...7, id: \.self) { day in
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
      
      if calendarManager.selectedDay > 0 {
        VStack {
          HStack {
            Image("pink_circle")
              .resizable()
              .frame(width: containerSize.width * 0.03, height: containerSize.width * 0.03)
            Text(calendarManager.dateComment)
              .font(.system(size: 15, weight: .medium))
              .foregroundStyle(.black)
            
            Spacer()
          }
          .padding(.horizontal, 10)
          
          Text(calendarManager.selectedCommnets())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .font(.system(size: 13))
            .foregroundStyle(.black)
          
          Spacer()
          
          HStack{
            Spacer()
            
            let imageWidth: CGFloat = containerSize.width * 0.2
            let imageHeight: CGFloat = imageWidth * 101 / 238
            
            Button {
              navigationPath.append(NavigationDestination.comments)
            } label: {
              Image("blue_button")
                .resizable()
                .frame(width: imageWidth, height: imageHeight)
                .overlay {
                  Text("Details")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                }
            }
          }
          .frame(width: containerSize.width * 0.85)
          .padding(.bottom, 30)
        }
        .padding(.top, 10)
        .background(GradientRectangleView())
      }
    }
  }
}
