//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 25.11.22.
//

import SwiftUI

class DoCatchTryThrowsBootcampDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        }
        return (nil, URLError(.badURL))
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String {
        if !isActive {
            return "NEW TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    
    @Published var text: String = "Starting text."
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle() {
        /*let value = manager.getTitle()
        if let newTitle = value.title {
            text = newTitle
        } else if let error = value.error {
            text = error.localizedDescription
        }
         */
        
        /*let result = manager.getTitle2()
        
        switch result {
        case .success(let newTitle):
            text = newTitle
        case .failure(let error):
            text = error.localizedDescription
        }
         */
        
//        let newTitle = try! manager.getTitle3()
//        text = newTitle
        
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle {
                text = newTitle
            }

            let finalTitle = try manager.getTitle4()
            text = finalTitle
        } catch {
            text = error.localizedDescription
        }
        
    }
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
