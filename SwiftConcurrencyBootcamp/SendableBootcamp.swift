//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 7.12.22.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDataBase(userInfo: MyUserInfo) {
        
    }
}

struct MyUserInfo: Sendable {
    var name: String
}

final class MyClassUserInfo: @unchecked Sendable {
    
    private var name: String
    private let queue = DispatchQueue(label: "serial queue")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(_ name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyUserInfo(name: "info")
        await manager.updateDataBase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text("Hello, World!")
            .task {
                
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
