//
//  PropertyWrapper2Bootcamp.swift
//  SwiftfulThinkingAdvancedLearning
//
//  Created by Suppasit chuwatsawat on 10/6/2567 BE.
//

import SwiftUI

@propertyWrapper
struct Capitalize: DynamicProperty {
    @State private var value: String
    
    var wrappedValue: String {
        get {
            value
        }
        nonmutating set {
            value = newValue.capitalized
        }
    }

    init(wrappedValue: String) {
        self.value = wrappedValue.capitalized
    }
}

@propertyWrapper
struct Uppercase: DynamicProperty {
    @State private var value: String
    
    var wrappedValue: String {
        get {
            value
        }
        nonmutating set {
            value = newValue.uppercased()
        }
    }

    init(wrappedValue: String) {
        self.value = wrappedValue.uppercased()
    }
}

struct FileManagerKeypath<T: Codable> {
    let key: String
    let type: T.Type
}

struct FileManagerValues {
    static let  shared = FileManagerValues()
    private init() { }
    
    let userProfile = FileManagerKeypath(key: "user_profile", type: User.self)
}

import Combine

@propertyWrapper
struct FileManagerCodableStreamableProperty<T: Codable>: DynamicProperty {
    @State private var value: T?
    let key: String
    private var publisher: CurrentValueSubject<T?, Never>
    
    var wrappedValue: T? {
        get {
            value
        }
        nonmutating set {
            save(newValue: newValue)
        }
    }
    
    var projectedValue: CustomProjectedValue<T> {
        CustomProjectedValue(
            binding: Binding(
                get: { wrappedValue },
                set: { wrappedValue = $0 }
            ),
            publisher: publisher
        )
    }
    
//    var projectedValue: CurrentValueSubject<T?, Never> {
//        publisher
//    }
    
//    var projectedValue: Binding<T?> {
//        Binding(
//            get: { wrappedValue },
//            set: { wrappedValue = $0 }
//        )
//    }

    init(_ key: String) {
        self.key = key
        
        do {
            let url    = FileManager.documentsPath(key: key)
            let data   = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            publisher = CurrentValueSubject(object)
            print("SUCCESS READ")
        } catch {
            _value = State(wrappedValue: nil)
            publisher = CurrentValueSubject(nil)
            print("ERROR READ: \(error)")
        }
    }
    
    init(_ key: KeyPath<FileManagerValues, FileManagerKeypath<T>>) {
        let keyPath = FileManagerValues.shared[keyPath: key]
        let key = keyPath.key
        
        self.key = key
        
        do {
            let url    = FileManager.documentsPath(key: key)
            let data   = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            publisher = CurrentValueSubject(object)
            print("SUCCESS READ")
        } catch {
            _value = State(wrappedValue: nil)
            publisher = CurrentValueSubject(nil)
            print("ERROR READ: \(error)")
        }
    }
    
    private func save(newValue: T?) {
        do {
            let data = try JSONEncoder().encode(newValue)
            try data.write(to: FileManager.documentsPath(key: key))
            value = newValue
            publisher.send(newValue)
            print("SUCCESS SAVED")
        } catch {
            print("EEROR SAVING: \(error)")
        }
    }
}

@propertyWrapper
struct FileManagerCodableProperty<T: Codable>: DynamicProperty {
    @State private var value: T?
    let key: String
    
    var wrappedValue: T? {
        get {
            value
        }
        nonmutating set {
            save(newValue: newValue)
        }
    }
    
    var projectedValue: Binding<T?> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    
        /*
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
        })
        */
    }
    
    init(_ key: String) {
        self.key = key
        
        do {
            let url    = FileManager.documentsPath(key: key)
            let data   = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            print("SUCCESS READ")
        } catch {
            _value = State(wrappedValue: wrappedValue)
            print("ERROR READ: \(error)")
        }
    }
    
    init(_ key: KeyPath<FileManagerValues, FileManagerKeypath<T>>) {
        let keyPath = FileManagerValues.shared[keyPath: key]
        let key = keyPath.key
        
        self.key = key
        
        do {
            let url    = FileManager.documentsPath(key: key)
            let data   = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            print("SUCCESS READ")
        } catch {
            _value = State(wrappedValue: wrappedValue)
            print("ERROR READ: \(error)")
        }
    }
    
    func save(newValue: T?) {
        do {
            let data = try JSONEncoder().encode(newValue)
            try data.write(to: FileManager.documentsPath(key: key))
            value = newValue
            print("SUCCESS SAVED")
        } catch {
            print("EEROR SAVING: \(error)")
        }
    }
}

struct User: Codable {
    let name: String
    let age: Int
    let isPremium: Bool
}

struct CustomProjectedValue<T: Codable> {
    let binding: Binding<T?>
    let publisher: CurrentValueSubject<T?, Never>
    
    var stream: AsyncPublisher<CurrentValueSubject<T?, Never>> {
        publisher.values
    }
}


struct PropertyWrapper2Bootcamp: View {
    
    //@Capitalize private var title = "hello, world!"
    @Uppercase private var title = "hello, world!"
    //@FileManagerCodableProperty("user_profile") private var userProfile: User?
    //@FileManagerCodableProperty(\.userProfile) private var userProfile: User?
    //@FileManagerCodableProperty(\.userProfile) private var userProfile
    @FileManagerCodableStreamableProperty(\.userProfile) private var userProfile

    var body: some View {
        VStack(spacing: 40) {
            Button(title) {
                title = "new title".capitalized
            }
         
            SomeBindingView(userProfile: $userProfile.binding)
            Button(userProfile?.name ?? "no  value") {
                userProfile = User(name: "Rickey", age: 1111, isPremium: true)
            }
        }
        .onReceive($userProfile.publisher, perform: { newValue in
            print("RECEVE NEW VALUE OF: \(newValue)")
        })
        .task {
            for await newValue in $userProfile.stream {
                print("STREAM NEW VALUE OF: \(newValue)")
            }
        }
        .onAppear {
            print(NSHomeDirectory())
        }
    }
}

struct SomeBindingView: View {
    
    @Binding var userProfile: User?
    
    var body: some View {
        Button(userProfile?.name ?? "no  value") {
            userProfile = User(name: "Beer", age: 100, isPremium: true)
        }
    }
}

#Preview {
    PropertyWrapper2Bootcamp()
}
