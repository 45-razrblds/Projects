import SwiftUI

// MARK: - HistoryView
struct HistoryView: View {
    @Binding var calculations: [String]
    private let purpleGradient = Gradient(colors: [Color.purple, Color.indigo])

    var body: some View {
        VStack {
            if calculations.isEmpty {
                Text("Keine bisherigen Berechnungen")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                ScrollView {
                    ForEach(calculations, id: \.self) { calculation in
                        Text(calculation)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .frame(maxHeight: 200) // Optional: Begrenzung der Größe
            }
        }
        .padding()
        .background(LinearGradient(gradient: purpleGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(12)
    }
}

// MARK: - NeonCalculatorView
struct NeonCalculatorView: View {
    @State private var display: String = "0"
    @State private var calculations: [String] = []
    @State private var firstOperand: Double? = nil
    @State private var currentOperation: String? = nil
    @State private var isTypingNumber: Bool = false
    @State private var isScientificPopupVisible: Bool = false // State für die Popup-Textbox

    private let purpleGradient = Gradient(colors: [Color.purple, Color.indigo])
    private let buttonSize: CGFloat = 70
    private let buttonSpacing: CGFloat = 12

    var body: some View {
        ZStack {
            LinearGradient(gradient: purpleGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: buttonSpacing) {
                // Display-Bereich
                Text(display)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
                    .onTapGesture {
                        if display == "∞" || display == "0/0" {
                            isScientificPopupVisible.toggle()
                        }
                    }

                // History-Bereich
                HistoryView(calculations: $calculations)
                    .padding()

                // Tastenbereich
                ForEach(calculatorButtonRows, id: \.self) { row in
                    HStack(spacing: buttonSpacing) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                buttonTapped(button)
                            }) {
                                Text(button)
                                    .font(.title)
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
            .padding()

            // Wissenschaftliche Erklärung als Popup
            if isScientificPopupVisible {
                VStack {
                    Text("Wissenschaftliche Erklärung")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()

                    ScrollView {
                        Text("""
                            In der Mathematik ist die Division von 0 durch 0 nicht definiert, da mehrere widersprüchliche Ergebnisse möglich sind. \
                            Man kann jedoch argumentieren, dass jede Zahl beliebig oft in 0 passt. Diese Idee führt zum Konzept der Unendlichkeit: \
                            \n\n0 ÷ 0 = ∞ (theoretisch)\n\n
                            Dies ist jedoch eine Vereinfachung, die in der Praxis problematisch ist.
                            Wissenschaftliche Ansätze wie der Grenzwert-Ansatz (L'Hopitals Regel) zeigen:
                            \n\n lim (x → 0) x/x = 1
                            """)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(maxHeight: 200)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)

                    Button("Schließen") {
                        isScientificPopupVisible.toggle()
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
            }
        }
    }

    private var calculatorButtonRows: [[String]] {
        [
            ["C", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", ".", "=", "←"]
        ]
    }

    private func buttonTapped(_ button: String) {
        switch button {
        case "C":
            // Zurücksetzen
            display = "0"
            firstOperand = nil
            currentOperation = nil
            calculations.removeAll()
            isTypingNumber = false

        case "←":
            // Letztes Zeichen löschen
            if isTypingNumber && !display.isEmpty {
                display.removeLast()
                if display.isEmpty {
                    display = "0"
                    isTypingNumber = false
                }
            }

        case "±":
            // Vorzeichen ändern
            if let value = Double(display) {
                display = String(-value)
            }

        case "%":
            // Prozent berechnen
            if let value = Double(display) {
                display = String(value / 100)
            }

        case "÷", "×", "−", "+":
            // Operation starten
            firstOperand = Double(display)
            currentOperation = button
            isTypingNumber = false

        case "=":
            // Operation abschließen
            if let operation = currentOperation,
               let firstValue = firstOperand,
               let secondValue = Double(display) {
                let result: Double
                switch operation {
                case "+":
                    result = firstValue + secondValue
                case "−":
                    result = firstValue - secondValue
                case "×":
                    result = firstValue * secondValue
                case "÷":
                    result = secondValue != 0 ? firstValue / secondValue : .infinity // Unendlich bei 0/0
                default:
                    return
                }
                display = String(result)
                calculations.append("\(firstValue) \(operation) \(secondValue) = \(display)")
                currentOperation = nil
                firstOperand = nil
                isTypingNumber = false
            }

        default: // Zahlen oder Punkt
            if isTypingNumber {
                display += button
            } else {
                display = button
                isTypingNumber = true
            }
        }
    }
}