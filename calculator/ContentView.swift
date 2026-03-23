// ContentView.swift
import SwiftUI
import Combine

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
