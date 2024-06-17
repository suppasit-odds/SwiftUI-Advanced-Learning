//
//  SubscriptsBootcamp.swift
//  SwiftfulThinkingAdvancedLearning
//
//  Created by Suppasit chuwatsawat on 15/6/2567 BE.
//

import SwiftUI

extension Array where Element == String {
 
    /*
    func getItem(atIndex: Int) -> Element? {
        for (index, item) in self.enumerated() {
            if index == atIndex {
                return item
            }
        }
        return nil
    }
    
    subscript(atIndex: Int) -> Element? {
        for (index, item) in self.enumerated() {
            if index == atIndex {
                return item
            }
        }
        return nil
    }
    */
    
    subscript(value: String) -> Element? {
        self.first(where: { $0 == value })
    }
    
}

struct Address {
    let street: String
    let city: City
}

struct City {
    let name: String
    let state: String
}

struct Customer {
    let name: String
    let address: Address
 
    // Return an optional
    /*
    subscript(value: String) -> String? {
        switch value {
        case "name": return name
        case "address": return address
        default: return nil
        }
    }
    */
    
    subscript(value: String) -> String {
        switch value {
        case "name": return name
        case "address": return "\(address.street), \(address.city.name)"
        default: fatalError()
        }
    }
    
    subscript(index: Int) -> String {
        switch index {
        case 0: return name
        case 1: return "\(address.street), \(address.city.name)"
        default: fatalError()
        }
    }
}

struct SubscriptsBootcamp: View {
    
    @State private var myArray: [String] = ["one", "two", "three"]
    @State private var selectedItem: String? = nil
    
    var body: some View {
        VStack {
            ForEach(myArray, id: \.self) { string in
                Text(string)
            }
            Text("SELECTED: \(selectedItem ?? "none")")
        }
        .onAppear {
//            selectedItem = myArray.getItem(atIndex: 1)
            let customer = Customer(
                name: "Nick",
                address: Address(
                    street: "Main Street",
                    city: City(name: "New York", state: "New York"
                    )
                )
            )
            
//            selectedItem = customer.name
//            selectedItem = customer[keyPath: \.name]
            selectedItem  = customer["address"]
//            selectedItem  = customer[0]

//            selectedItem = myArray[0]
        }
    }
}

#Preview {
    SubscriptsBootcamp()
}
