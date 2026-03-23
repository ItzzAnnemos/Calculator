//
//  Models.swift
//  calculator
//
//  Created by Nikola Serafimov on 23.3.26.
//

import SwiftUI

enum CalcButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case add = "+", subtract = "−", multiply = "×", divide = "÷"
    case equals = "=", clear = "AC", decimal = ".", toggleSign = "+/−"
    case percent = "%"
    // Scientific
    case sin = "sin", cos = "cos", tan = "tan"
    case sqrt = "√", squared = "x²", log = "log"
    case pi = "π", exp = "eˣ", inv = "1/x"

    var buttonColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equals:
            return .orange
        case .clear, .toggleSign, .percent:
            return Color(.lightGray)
        case .sin, .cos, .tan, .sqrt, .squared, .log, .pi, .exp, .inv:
            return Color(.darkGray)
        default:
            return Color(.darkGray).opacity(0.8)
        }
    }
}
