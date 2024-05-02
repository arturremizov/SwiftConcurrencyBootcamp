//
//  AsyncStreamBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 2.05.24.
//

import SwiftUI

class AsyncStreamDataManager {
    
    func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeData(handler: { value in
                continuation.yield(value)
            }, onFinish: { error in
                continuation.finish(throwing: error)
            })
        }
    }
    
    func getFakeData(handler: @escaping (_ value: Int) -> Void,
                     onFinish: @escaping (_ error: Error?) -> Void) {
        
        let items = [1,2,3,4,5,6,7,8,9,10]
        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)) {
                handler(item)
                print("NEW DATA: \(item)")
                if item == items.last {
                    onFinish(nil)
                }
            }
        }
    }
}

@MainActor
final class AsyncStreamViewModel: ObservableObject {
    @Published private(set) var currentNumber: Int = 0
    private let manager = AsyncStreamDataManager()
   
    func onViewAppear() {
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }
        let task = Task {
            do {
                for try await value in manager.getAsyncStream().dropFirst(2) {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            task.cancel()
            print("TASK CANCELLED!")
        }
    }
}

struct AsyncStreamBootcamp: View {
    @StateObject private var viewModel = AsyncStreamViewModel()
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    AsyncStreamBootcamp()
}
