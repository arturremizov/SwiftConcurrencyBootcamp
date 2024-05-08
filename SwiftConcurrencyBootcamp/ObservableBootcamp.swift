//
//  ObservableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 8.05.24.
//

import SwiftUI

actor TitleDatabase {
    func getNewTitle() -> String {
        "Some new title!"
    }
}

@Observable
class ObservableViewModel {
    @MainActor var title: String = "Starting title"
    @ObservationIgnored private let database = TitleDatabase()
    
    func updateTitle() {
        Task { @MainActor in 
            title = await database.getNewTitle()
            print(Thread.current)
        }
    }
}

struct ObservableBootcamp: View {
    @State private var viewModel = ObservableViewModel()
    var body: some View {
        Text(viewModel.title)
            .onAppear {
                viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableBootcamp()
}
