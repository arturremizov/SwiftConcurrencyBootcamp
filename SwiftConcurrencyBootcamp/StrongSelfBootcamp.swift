//
//  StrongSelfBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 7.09.23.
//

import SwiftUI

final class StrongSelfDataService {
    func getData() async -> String {
        "Updated data!"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    
    @Published var data: String = "Some title!"
    let dataService = StrongSelfDataService()
    private var currentTask: Task<Void, Never>? = nil
    private var tasks: [Task<Void, Never>] = []

    func cancelTasks() {
        currentTask?.cancel()
        currentTask = nil
        
        tasks.forEach { $0.cancel() }
        tasks = []
    }
    
    // This implies a strong reference...
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This is a strong reference...
    func updateData2() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // This is a strong reference...
    func updateData3() {
        Task { [self] in
            self.data = await self.dataService.getData()
        }
    }
    
    // This is a weak reference...
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    // We don't need to manage weak/strong
    // We can manage the Task!
    func updateData5() {
        currentTask = Task {
            data = await dataService.getData()
        }
    }
    
    func updateData6() {
        let task1 = Task {
            data = await dataService.getData()
        }
        tasks.append(task1)
        let task2 = Task {
            data = await dataService.getData()
        }
        tasks.append(task2)
    }
    
    // WE purposely do not cancel tasks to keep strong references
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData8() async {
        data = await dataService.getData()
    }
}

struct StrongSelfBootcamp: View {
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}

struct StrongSelfBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StrongSelfBootcamp()
    }
}
