import Foundation
import Observation
import SwiftData

struct HistoricoRowData: Identifiable {
    let id: UUID
    let ponto: PontoDiario
    let data: String
    let status: String
    let empresa: String
    let horas: String
    let valor: String
    let isIncomplete: Bool
}

struct HistoricoSection: Identifiable {
    let id: String
    let titulo: String
    let rows: [HistoricoRowData]
}

@Observable
final class HistoricoViewModel {
    var secoes: [HistoricoSection] = []
    var pontoPendenteExclusao: PontoDiario?

    func update(pontos: [PontoDiario], calendar: Calendar = .current) {
        let grouped = Dictionary(grouping: pontos.sorted(by: { $0.dataReferencia > $1.dataReferencia })) {
            monthKey(for: $0.dataReferencia, calendar: calendar)
        }

        secoes = grouped.keys.sorted(by: >).compactMap { key in
            guard let entries = grouped[key], let date = monthDate(from: key) else {
                return nil
            }

            return HistoricoSection(
                id: key,
                titulo: date.formatted(.dateTime.month(.wide).year()),
                rows: entries.map { ponto in
                    HistoricoRowData(
                        id: ponto.id,
                        ponto: ponto,
                        data: ponto.dataReferencia.formatted(.dateTime.day().month(.abbreviated)),
                        status: ponto.status.titulo,
                        empresa: ponto.nomeEmpresaSnapshot.isEmpty ? "Sem empresa" : ponto.nomeEmpresaSnapshot,
                        horas: RoninFormatters.horas(ponto.totalHorasTrabalhadas),
                        valor: ponto.valorFaturadoDia.formatted(RoninFormatters.currencyBRL),
                        isIncomplete: ponto.status != .completo
                    )
                }
            )
        }
    }

    private func monthKey(for date: Date, calendar: Calendar) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
    }

    private func monthDate(from key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: key)
    }

    func excluir(_ ponto: PontoDiario, using modelContext: ModelContext) throws {
        modelContext.delete(ponto)
        try modelContext.save()
    }

    func solicitarExclusao(_ ponto: PontoDiario) {
        pontoPendenteExclusao = ponto
    }

    func cancelarExclusao() {
        pontoPendenteExclusao = nil
    }
}
