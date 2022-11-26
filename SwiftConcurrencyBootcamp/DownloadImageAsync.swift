//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 26.11.22.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            (200..<300).contains(response.statusCode)
        else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, responce) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: responce)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    
    func fetchImage() async {
//        loader.downloadWithEscaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
        
//        loader.downloadWithCombine()
//            .replaceError(with: nil)
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$image)
        
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
