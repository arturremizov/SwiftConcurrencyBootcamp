//
//  PhotosPickerBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 12.09.23.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotosPickerBootcampViewModel: ObservableObject {
    @Published var pickerSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: pickerSelection)
        }
    }
    @Published private(set) var selectedImage: UIImage? = nil
    
    @Published var pickerSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: pickerSelections)
        }
    }
    @Published private(set) var selectedImages: [UIImage] = []
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            do {
                for selection in selections {
                    let data = try await selection.loadTransferable(type: Data.self)
                    guard let data, let uiImage = UIImage(data: data) else {
                        throw URLError(.badServerResponse)
                    }
                    images.append(uiImage)
                }
            } catch {
                print(error)
            }
            self.selectedImages = images
        }
    }
}

struct PhotosPickerBootcamp: View {
    @StateObject private var viewModel = PhotosPickerBootcampViewModel()
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.pickerSelection, matching: .images) {
                Text("Open the photo picker")
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $viewModel.pickerSelections, matching: .images) {
                Text("Open the photos picker")
            }
        }
    }
}

struct PhotosPickerBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        PhotosPickerBootcamp()
    }
}
