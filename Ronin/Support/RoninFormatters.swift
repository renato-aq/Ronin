import Foundation

enum RoninFormatters {
    static let currencyBRL: FloatingPointFormatStyle<Double>.Currency = .currency(code: "BRL")
    static let hourMinute: Date.FormatStyle = .dateTime.hour().minute()
    static let hourMinuteSecond: Date.FormatStyle = .dateTime.hour().minute().second()
    static let decimalSeparator = Locale.current.decimalSeparator ?? ","

    static func horas(_ intervalo: TimeInterval) -> String {
        let totalSeconds = max(0, Int(intervalo.rounded()))
        let horas = totalSeconds / 3600
        let minutos = (totalSeconds % 3600) / 60
        let segundos = totalSeconds % 60
        return "\(horas)h \(minutos)m \(segundos)s"
    }

    static func decimalInput(_ value: Double) -> String {
        guard value > 0 else { return "" }

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    static func parseDecimalInput(_ text: String) -> Double? {
        guard isValidCurrencyInput(text) else { return nil }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = normalizedDecimalInput(trimmed)

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.number(from: normalized)?.doubleValue
    }

    static func isValidCurrencyInput(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let separatorPattern = "[\\.,]"
        let pattern = #"^\d+(\#(separatorPattern)\d{1,2})?$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    static func currencyValidationMessage(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard isValidCurrencyInput(trimmed) else {
            return "Informe um valor monetário válido com até 2 casas decimais."
        }
        return nil
    }

    static func sanitizeCurrencyInput(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        var result = ""
        var hasSeparator = false
        var decimalCount = 0

        for character in trimmed {
            if character.isWholeNumber {
                if hasSeparator {
                    guard decimalCount < 2 else { continue }
                    decimalCount += 1
                }
                result.append(character)
                continue
            }

            if character == "," || character == "." {
                guard !hasSeparator, !result.isEmpty else { continue }
                hasSeparator = true
                result.append(Character(decimalSeparator))
            }
        }

        return result
    }

    private static func normalizedDecimalInput(_ text: String) -> String {
        if decimalSeparator == "," {
            return text.replacingOccurrences(of: ".", with: "")
        }
        return text.replacingOccurrences(of: ",", with: "")
    }
}
