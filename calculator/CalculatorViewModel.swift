//
//  CalculatorViewModel.swift
//  calculator
//
//  Created by Nikola Serafimov on 23.3.26.
//

import SwiftUI
import Combine

class CalculatorViewModel: ObservableObject {
    @Published var display = "0"
    @Published var equation = ""
    private var currentValue: Double = 0
    private var storedValue: Double = 0
    private var currentOp: CalcButton? = nil
    private var justEvaluated = false

    func buttonTapped(_ button: CalcButton) {
        let vm = self
        vm.handle(button)
        DispatchQueue.main.async {
            self.display = vm.display
            self.currentValue = vm.currentValue
            self.storedValue = vm.storedValue
            self.currentOp = vm.currentOp
            self.justEvaluated = vm.justEvaluated
        }
    }

    private func handle(_ button: CalcButton) {
        switch button {
        case .clear:
            display = "0"; currentValue = 0; storedValue = 0; currentOp = nil; justEvaluated = false; equation = ""

        case .toggleSign:
            currentValue = -currentValue
            display = format(currentValue)

        case .percent:
            currentValue /= 100
            display = format(currentValue)

        case .decimal:
            if !display.contains(".") { display += "." }

        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if justEvaluated { display = button.rawValue; justEvaluated = false }
            else { display = display == "0" ? button.rawValue : display + button.rawValue }
            currentValue = Double(display) ?? 0

        case .add, .subtract, .multiply, .divide:
            storedValue = currentValue
            equation = display + " " + button.rawValue + " "
            currentOp = button
            justEvaluated = true

        case .equals:
            guard let op = currentOp else { return }
            let result: Double
            switch op {
            case .add:      result = storedValue + currentValue
            case .subtract: result = storedValue - currentValue
            case .multiply: result = storedValue * currentValue
            case .divide:   result = currentValue != 0 ? storedValue / currentValue : 0
            default:        result = currentValue
            }
            equation = equation + display + " ="
            currentValue = result
            display = format(result)
            currentOp = nil
            justEvaluated = true

        // Scientific
        case .sin:     equation = "sin(\(display)) ="; currentValue = sin(currentValue * .pi / 180); display = format(currentValue)
        case .cos:     equation = "cos(\(display)) ="; currentValue = cos(currentValue * .pi / 180); display = format(currentValue)
        case .tan:     equation = "tan(\(display)) ="; currentValue = tan(currentValue * .pi / 180); display = format(currentValue)
        case .sqrt:    equation = "√(\(display)) ="; currentValue = sqrt(currentValue);            display = format(currentValue)
        case .squared: equation = "\(display)² ="; currentValue = currentValue * currentValue;   display = format(currentValue)
        case .log:     equation = "log(\(display)) ="; currentValue = log10(currentValue);           display = format(currentValue)
        case .pi:      equation = "π ="; currentValue = Double.pi;                     display = format(currentValue)
        case .exp:     equation = "e^(\(display)) ="; currentValue = exp(currentValue);             display = format(currentValue)
        case .inv:     equation = "1/(\(display)) ="; currentValue = currentValue != 0 ? 1 / currentValue : 0; display = format(currentValue)
        }
    }

    private func format(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 && abs(value) < 1e12 {
            return String(Int(value))
        }
        return String(format: "%.6g", value)
    }
}
