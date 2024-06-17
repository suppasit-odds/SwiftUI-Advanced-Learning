//
//  CustomOperatorBootcamp.swift
//  SwiftfulThinkingAdvancedLearning
//
//  Created by Suppasit chuwatsawat on 17/6/2567 BE.
//

import SwiftUI

struct CustomOperatorBootcamp: View {
    
    @State private var value: Double = 0.0
    
    var body: some View {
        Text("\(value)")
            .onAppear {
//                value = 5 + 5
//                value = 5 / 2
//                value = (5 + 5) / 2
//                value = 5 +/ 5
//                value = 6 ++/ 3
//                value = 6 ^^^ 5
                let someValue: Int = 5
                value = someValue => Double.self
            }
    }
}

infix operator +/
infix operator ++/
infix operator ^^^
infix operator =>

extension FloatingPoint {
    static func +/ (lhs: Self, rhs: Self) -> Self {
        (lhs + rhs) / 2
    }
    
    static func ++/ (lhs: Self, rhs: Self) -> Self {
        (lhs + lhs) / rhs
    }
    
    static func ^^^ (lhs: Self, rhs: Self) -> Self {
        max(lhs, rhs)
    }
}

protocol InitFromBinaryFloatingPoint {
    init<Source>(_ value: Source) where Source : BinaryInteger
}

extension Double: InitFromBinaryFloatingPoint {
    
}

extension BinaryInteger {
    static func => <T: InitFromBinaryFloatingPoint>(value: Self, newType: T.Type) -> T {
        T(value)
    }
}

#Preview {
    CustomOperatorBootcamp()
}
