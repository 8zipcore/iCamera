//
//  MainView.swift
//  iCamera
//
//  Created by 홍승아 on 9/9/24.
//

import SwiftUI

struct MainView: View {
  
  enum Screen {
    case camera
    case gallery
    case calendar
    case comments
    case test
    
    var title: String {
      switch self {
      case .camera:
        return "Camera"
      case .gallery:
        return "Photo"
      case .calendar:
        return "Calendar"
      default:
        return ""
      }
    }
  }
  
  @State private var navigationPath = NavigationPath()
  @StateObject private var calendarManager = CalendarManager.shared
  
  var body: some View {
    NavigationStack(path: $navigationPath) {
      VStack(spacing: .mediumPadding){
        menuSection()
        
        calendarSection()
        
        Spacer()
      }
      .padding(.vertical, .defaultPadding)
      .padding(.horizontal, .mediumPadding)
      .grayGridentBackground()
      .navigationDestination(for: Screen.self) { screen in
        switch screen {
        case .camera:
          CameraView(navigationPath: $navigationPath)
        case .gallery:
          GalleryView(navigationPath: $navigationPath, viewType: .main)
        case .calendar:
          CalendarView(navigationPath: $navigationPath, calendarManager: calendarManager)
        case .comments:
          CommentsView(
            navigationPath: $navigationPath,
            calendarManager: calendarManager,
            viewType: .main
          )
        default:
          TestPhotoView(navigationPath: $navigationPath, image: UIImage(named: "test") ?? UIImage(), albumManager: AlbumViewModel())
        }
      }
      .navigationBar(.main)
      .edgesIgnoringSafeArea(.bottom)
      .onAppear{
        // CoreDataManager.shared.deleteAllData()
        calendarManager.fetchData()
        calendarManager.todayDate()
      }
    }
  }
}

// MARK: - Subviews
extension MainView {
  private func menuSection() -> some View {
    VStack(spacing: .defaultPadding) {
      Group {
        NavigationLink(value: Screen.camera) {
          ListView(title: Screen.camera.title)
        }
        
        NavigationLink(value: Screen.gallery) {
          ListView(title: Screen.gallery.title)
        }
        
        NavigationLink(value: Screen.calendar) {
          ListView(title: Screen.calendar.title)
        }
      }
      .frame(height: 18)
      .frame(maxWidth: .infinity)
    }
    .padding(.defaultPadding)
    .roundedBackground()
  }
  
  private func calendarSection() -> some View {
    HStack(spacing: .smallPadding){
      NavigationLink(value: Screen.comments) {
        Text("\(calendarManager.selectedDay)")
          .font(.system(size: 60, weight: .medium))
          .foregroundStyle(Colors.titleGray)
        
        VStack(spacing: 3){
          Group {
            Text(calendarManager.getWeekdays())
              .font(.system(size: 17, weight: .medium))
              .foregroundStyle(.black)
            
            Text(calendarManager.getMonthAndYear())
              .font(.system(size: 17, weight: .medium))
              .foregroundStyle(.black)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        Spacer()
        
        Image("arrow")
          .resizable()
          .frame(width: 16, height: 16)
      }
    }
    .padding(.horizontal, .defaultPadding)
    .roundedBackground()
  }
}
