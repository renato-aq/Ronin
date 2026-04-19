import Foundation

enum RoninFormatters {
    static let currencyBRL: FloatingPointFormatStyle<Double>.Currency = .currency(code: "BRL")
    static let hourMinute: Date.FormatStyle = .dateTime.hour().minute()
    static let hourMinuteSecond: Date.FormatStyle = .dateTime.hour().minute().second()

    static func horas(_ intervalo: TimeInterval) -> String {
        let totalSeconds = max(0, Int(intervalo.rounded()))
        let horas = totalSeconds / 3600
        let minutos = (totalSeconds % 3600) / 60
        let segundos = totalSeconds % 60
        return "\(horas)h \(minutos)m \(segundos)s"
    }
}
