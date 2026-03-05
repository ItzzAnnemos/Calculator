// ContentView.swift
import SwiftUI
import Combine

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

struct ContentView: View {
    @StateObject private var vm = CalculatorViewModel()
    @Environment(\.horizontalSizeClass) var hSizeClass

    // Portrait buttons
    let portraitButtons: [[CalcButton]] = [
        [.clear, .toggleSign, .percent, .divide],
        [.seven, .eight, .nine,  .multiply],
        [.four,  .five,  .six,   .subtract],
        [.one,   .two,   .three, .add],
        [.zero,  .decimal,       .equals]
    ]

    // Scientific extra column
    let sciButtons: [[CalcButton]] = [
        [.sin, .cos],
        [.tan, .sqrt],
        [.squared, .log],
        [.exp, .inv],
        [.pi ]
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                if geo.size.width > geo.size.height {
                    landscapeLayout(geo: geo)
                } else {
                    portraitLayout(geo: geo)
                }
            }
        }
    }

    // MARK: - Portrait
    func portraitLayout(geo: GeometryProxy) -> some View {
        let buttonSize = (geo.size.width - 5 * 12) / 4
        return VStack(spacing: 12) {
            Spacer()
            displayView
            ForEach(portraitButtons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { btn in
                        if btn == .zero {
                            calcButton(btn, width: buttonSize * 2 + 12, height: buttonSize)
                        } else {
                            calcButton(btn, width: buttonSize, height: buttonSize)
                        }
                    }
                }
            }
        }
        .padding(12)
    }

    // MARK: - Landscape
    func landscapeLayout(geo: GeometryProxy) -> some View {
        let totalW = geo.size.width - 4 * 12
        let sciW   = totalW * 0.35
        let calcW  = totalW * 0.65
        let btnH   = (geo.size.height - 6 * 26) / 5

        return HStack(spacing: 12) {
            // Scientific panel
            VStack(spacing: 10) {
                Spacer()
                ForEach(sciButtons, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { btn in
                            let w = btn == .pi ? (sciW - 2 * 10) / 2 * 2 + 10 : (sciW - 2 * 10) / 2
                            calcButton(btn, width: w, height: btnH)
                        }
                    }
                }
            }
            .padding(.leading, 12)

            VStack(spacing: 10) {
                Spacer()
                displayView
                ForEach(portraitButtons, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { btn in
                            let w = btn == .zero ? (calcW - 2 * 10) / 4 * 2 + 10 : (calcW - 3 * 10) / 4
                            calcButton(btn, width: w, height: btnH)
                        }
                    }
                }
            }
            .padding(.trailing, 12)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Shared Components
    var displayView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(vm.equation)
                .font(.system(size: 24, weight: .thin))
                .foregroundColor(.gray)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 8)
            Text(vm.display)
                .font(.system(size: 64, weight: .thin))
                .foregroundColor(.white)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 8)
        }
    }

    func calcButton(_ button: CalcButton, width: CGFloat, height: CGFloat) -> some View {
        Button(action: { vm.buttonTapped(button) }) {
            Text(button.rawValue)
                .font(.system(size: min(width, height) * 0.38, weight: .medium))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(button.buttonColor)
                .cornerRadius(height / 2)
        }
    }
}

#Preview {
    ContentView()
}
