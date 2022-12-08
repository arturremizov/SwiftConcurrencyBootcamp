//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 8.12.22.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(for: .seconds(2))
        
        myData.append("Banana")
        try? await Task.sleep(for: .seconds(2))
        
        myData.append("Orange")
        try? await Task.sleep(for: .seconds(2))
        
        myData.append("Watermellon")
    }
}


class AsyncPublisherBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        Task {
            await MainActor.run(body: {
                self.dataArray = ["ONE"]
            })
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
                break
            }
            await MainActor.run(body: {
                self.dataArray = ["TWO"]
            })
        }
        
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$dataArray)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
