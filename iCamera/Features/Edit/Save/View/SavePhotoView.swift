//
//  SavePhotoView.swift
//  iCamera
//
//  Created by 홍승아 on 11/23/24.
//

import SwiftUI

struct SavePhotoView: View {
  @Binding var navigationPath: NavigationPath
  @State var image: UIImage
  @StateObject var albumManager = AlbumViewModel()
  
  @State private var showShareSheet = false
  @State private var isSaved = false
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        titleSection(containerHeight: geometry.size.height)
        
        image(containerSize: geometry.size)
        
        saveButton(containerWidth: geometry.size.width)
        
        shareButton(containerSize: geometry.size)
        
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .background(GradientRectangleView())
      .navigationBar(
        .save,
        onLeadingButtonTap: {
          dismiss()
        },
        trailingButtonType: .home,
        onTrailingButtonTap: {
          navigationPath.removeLast(navigationPath.count)
        }
      )
    }
  }
}

// MARK: - Subviews
extension SavePhotoView {
  private func titleSection(containerHeight: CGFloat) -> some View {
    VStack{
      Spacer()
      
      Text("Upload Your Lucky Photo! ࣪ꕤ˚₊⊹")
        .font(.system(size: 19, weight: .medium))
        .foregroundStyle(.black)
    }
    .frame(height: containerHeight * 0.1)
  }
  
  private func image(containerSize: CGSize) -> some View {
    Image(uiImage: image)
      .resizable()
      .scaledToFit()
      .frame(maxWidth: containerSize.width * 0.9, maxHeight: containerSize.height * 0.45)
      .padding(.vertical, 40)
  }
  
  private func saveButton(containerWidth: CGFloat) -> some View {
    Button {
      Task {
        await albumManager.saveImageToPhotos(image: image)
        isSaved = true
      }
    } label: {
      let imageWidth: CGFloat = containerWidth * 0.19
      let imageHeight: CGFloat = imageWidth * 54 / 119
      
      ZStack{
        Image(isSaved ? "gray_button" : "blue_button")
          .resizable()
          .frame(width: imageWidth, height: imageHeight)
        
        Text(isSaved ? "Complete" : "Save")
          .font(.system(size: isSaved ? 12 : 14, weight: .semibold))
          .foregroundStyle(isSaved ? Colors.titleGray : .white)
      }
    }
  }
  
  private func shareButton(containerSize: CGSize) -> some View {
    Button {
      showShareSheet.toggle()
    } label: {
      let imageWidth: CGFloat = containerSize.width * 0.19
      let imageHeight: CGFloat = imageWidth * 54 / 119
      
      ZStack{
        Image("blue_button")
          .resizable()
          .frame(width: imageWidth, height: imageHeight)
        Text("Share")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(.white)
      }
    }
    .padding(.top, 30)
    .sheet(isPresented: $showShareSheet) {
      ShareSheet(
        items: [image],
        viewSize: CGSize(width: containerSize.width, height: containerSize.height * 0.5)
      )
    }
  }
}
