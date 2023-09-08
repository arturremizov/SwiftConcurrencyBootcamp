//
//  RefreshableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 8.09.23.
//

import SwiftUI

final class RefreshableDataService {
    func getData() async throws -> [String] {
        try await Task.sleep(for: .seconds(2))
        return ["Apple", "Orange", "Banana"].shuffled()
    }
}
 
@MainActor
final class RefreshableBootcampViewModel: ObservableObject {
    
    @Published private(set) var items: [String] = []
    private let dataService = RefreshableDataService(
    )
    func loadData() async {
        do {
            items = try await dataService.getData()
        } catch {
            print(error)
        }
    }
}

struct RefreshableBootcamp: View {
    @StateObject private var viewModel = RefreshableBootcampViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Refreshable")
            .refreshable {
                await viewModel.loadData()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

struct RefreshableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableBootcamp()
    }
}
