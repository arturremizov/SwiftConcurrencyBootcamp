//
//  SearchableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 11.09.23.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String, CaseIterable {
    case american, itailan, japanese
}

final class RestaurantManager {
    
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .itailan),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american)
        ]
    }
}

@MainActor
final class SearchableBootcampViewModel: ObservableObject {
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    private let manager = RestaurantManager()
    private var subscriptions: [AnyCancellable] = []
    
    var isSearching: Bool { !searchText.isEmpty }
    var isShowingSearchSuggestions: Bool { searchText.count < 5 }
    
    init() {
        addSubscribers()
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map { SearchScopeOption.cuisine(option: $0) }
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        guard isShowingSearchSuggestions else {
            return []
        }
        var suggestions: [String] = []
        let search = searchText.lowercased()
        
        switch search {
        case "pa":
            suggestions.append("Pasta")
        case "su":
            suggestions.append("Sushi")
        case "bu":
            suggestions.append("Burger")
        default:
            break
        }
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        CuisineOption.allCases.forEach {
            suggestions.append($0.rawValue.capitalized)
        }
        
        return suggestions
    }
    
    func getRestaurantSuggestions() -> [Restaurant] {
        guard isShowingSearchSuggestions else {
            return []
        }
        var suggestions: [Restaurant] = []
        let search = searchText.lowercased()
        
        switch search {
        case "ita":
            suggestions.append(contentsOf: allRestaurants.filter { $0.cuisine == .itailan })
        case "jap":
            suggestions.append(contentsOf: allRestaurants.filter { $0.cuisine == .japanese })

        default:
            break
        }
        return suggestions
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] text, searchScope in
                self?.filterRestaurants(searchText: text, searchScope: searchScope)
            }
            .store(in: &subscriptions)
    }
    
    private func filterRestaurants(searchText: String, searchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            self.searchScope = .all
            return
        }
         

        let search = searchText.lowercased()
        filteredRestaurants = allRestaurants.filter {
            if case let .cuisine(option) = searchScope {
                return $0.title.lowercased().contains(search) &&
                $0.cuisine == option
            }
            return $0.title.lowercased().contains(search) ||
            $0.cuisine.rawValue.lowercased().contains(search)
        }
    }
}

struct SearchableBootcamp: View {
    @StateObject private var viewModel = SearchableBootcampViewModel()
    var body: some View {
        VStack {
            List(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                NavigationLink(value: restaurant) {
                    restaurantRow(restaurant: restaurant)
                }
            }
            
            Text("VM isSearching: \(viewModel.isSearching.description)")
            SeachChildView()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restaurants...")
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        .searchSuggestions {
            ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { restaurant in
                NavigationLink(value: restaurant) {
                    Text(restaurant.title)
                }
            }
        }
        //        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Text(restaurant.title)
                .font(.headline)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SeachChildView: View {
    @Environment(\.isSearching) private var isSearching
    var body: some View {
        Text("Child View is searching: \(isSearching.description)")
    }
}

struct SearchableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchableBootcamp()
        }
    }
}
