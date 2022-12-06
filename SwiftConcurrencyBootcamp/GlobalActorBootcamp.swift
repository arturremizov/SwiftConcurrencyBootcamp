//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 6.12.22.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
    
    static let shared = MyNewDataManager()
    
}

actor MyNewDataManager {
    
    func getDataFromDataBase() -> [String] {
        return ["One", "Two", "Three", "Four", "FIVE", "Six"]
    }
}

@MainActor class GlobalActorBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
//    nonisolated
    @MyFirstGlobalActor func getData() {
        
        // HEAVY COMPLEX METHODS
        
        Task {
            let data = await manager.getDataFromDataBase()
            await MainActor.run(body: {
                self.dataArray = data
            })
        }
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { text in
                    Text(text)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
