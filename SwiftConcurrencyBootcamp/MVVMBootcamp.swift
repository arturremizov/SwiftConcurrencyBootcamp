//
//  MVVMBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 8.09.23.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        "Some Data!"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some Data!"
    }
}

@MainActor
final class MVVMBootcampViewModel: ObservableObject {
    
    private let managerClass = MyManagerClass()
    private let managerActor = MyManagerActor()
    private var tasks: [Task<Void, Never>] = []
    
    @MainActor @Published private(set) var myData: String = "Starting text"
    
    func cancelTasks() {
        tasks.forEach { $0.cancel() }
        tasks = []
    }
    
    
    func onCallToActionButtonPressed() {
        let task = Task {
            do {
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
}

struct MVVMBootcamp: View {
    @StateObject private var viewModel = MVVMBootcampViewModel()
    var body: some View {
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

struct MVVMBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        MVVMBootcamp()
    }
}
