//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 28.11.22.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        
//        for x in array {
//            try Task.checkCancellation()
//        }
        
        try? await Task.sleep(for: .seconds(5))
        guard let url = URL(string: "https://picsum.photos/1000") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                print("IMAGE RETURNED SUCCESSFULLY!")
                self.image = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        guard let url = URL(string: "https://picsum.photos/1000") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("CLICK ME! 🤓") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    
    @StateObject var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40.0) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//            fetchImageTask = Task {
//                await viewModel.fetchImage()
//            }
////            Task {
////                print(Thread.current)
////                print(Task.currentPriority)
////                await viewModel.fetchImage2()
////            }
//
////            Task(priority: .high) {
//////                try? await Task.sleep(for:.seconds(2))
////                await Task.yield()
////                print("HIGH: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority: .userInitiated) {
////                print("USER INITIATED: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .medium) {
////                print("MEDIUM: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .low) {
////                print("LOW: \(Thread.current) : \(Task.currentPriority)")
////            }
////            Task(priority: .utility) {
////                print("UTIITY: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .background) {
////                print("BACKGROUND: \(Thread.current) : \(Task.currentPriority)")
////            }
//
////            Task(priority: .low) {
////                print("LOW : \(Thread.current) : \(Task.currentPriority)")
////
////                Task.detached {
////                    print("detached : \(Thread.current) : \(Task.currentPriority)")
////                }
////            }
//
//
//
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
