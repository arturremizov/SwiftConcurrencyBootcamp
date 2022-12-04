//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Artur Remizov on 3.12.22.
//

import SwiftUI

struct StructClassActorBootcamp: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                runTest()
            }
    }
}

struct MyStruct {
    var title: String
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(_ title: String) {
        self.title = title
    }
}

extension StructClassActorBootcamp {
    
    private func runTest() {
        print("Test started")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        actorsTest1()
    }
    
    private func printDivider() {
        print("\n - - - - - - - - - - - - - - - -\n")
    }
    
    private func structTest1() {
        print("printDivider")
        let objectA = MyStruct(title: "Starting title!")
        print("Object A: ", objectA.title)
        
        print("Pass the values of object A to object B")
        var objectB = objectA
        print("Object B: ", objectB.title)
        
        objectB.title = "Second title!"
        print("Object B title changed.")
        
        print("Object A: ", objectA.title)
        print("Object B: ", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "Starting title!")
        print("Object A: ", objectA.title)
        
        print("Pass the reverence of object A to object B")
        let objectB = objectA
        print("Object B: ", objectB.title)
        
        objectB.title = "Second title!"
        print("Object B title changed.")
        
        print("Object A: ", objectA.title)
        print("Object B: ", objectB.title)
    }
    
    private func actorsTest1() {
        Task {
            print("classTest1")
            let objectA = MyActor(title: "Starting title!")
            await print("Object A: ", objectA.title)
            
            print("Pass the reverence of object A to object B")
            let objectB = objectA
            await print("Object B: ", objectB.title)
            
            await objectB.updateTitle("Second title!")
            print("Object B title changed.")
            
            await print("Object A: ", objectA.title)
            await print("Object B: ", objectB.title)
        }
    }
}
