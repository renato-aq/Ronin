import Foundation
import Observation
import SwiftData

enum PontoHorarioField {
    case entrada
    case idaAlmoco
    case voltaAlmoco
    case fimExpediente
}

@Observable
final class PontoDetailViewModel {
    let ponto: PontoDiario

    var draftEntrada: Date
    var draftIdaAlmoco: Date
    var draftVoltaAlmoco: Date
    var draftFimExpediente: Date
    var hasEntrada: Bool
    var hasIdaAlmoco: Bool
    var hasVoltaAlmoco: Bool
    var hasFimExpediente: Bool

    init(ponto: PontoDiario) {
        self.ponto = ponto

        let baseDate = ponto.dataReferencia
        draftEntrada = ponto.entrada ?? baseDate
        draftIdaAlmoco = ponto.idaAlmoco ?? baseDate
        draftVoltaAlmoco = ponto.voltaAlmoco ?? baseDate
        draftFimExpediente = ponto.fimExpediente ?? baseDate
        hasEntrada = ponto.entrada != nil
        hasIdaAlmoco = ponto.idaAlmoco != nil
        hasVoltaAlmoco = ponto.voltaAlmoco != nil
        hasFimExpediente = ponto.fimExpediente != nil
    }

    var dataFormatada: String {
        ponto.dataReferencia.formatted(.dateTime.day().month(.wide).year())
    }

    var nomeEmpresa: String {
        ponto.nomeEmpresaSnapshot
    }

    var valorHoraAplicadoFormatado: String {
        ponto.valorHoraAplicado.formatted(RoninFormatters.currencyBRL)
    }

    var horasCalculadas: String {
        RoninFormatters.horas(ponto.totalHorasTrabalhadas)
    }

    var valorFaturadoFormatado: String {
        ponto.valorFaturadoDia.formatted(RoninFormatters.currencyBRL)
    }

    func segundo(for field: PontoHorarioField) -> Int {
        let date = date(for: field)
        return Calendar.current.component(.second, from: date)
    }

    func setSegundo(_ segundo: Int, for field: PontoHorarioField) {
        let calendar = Calendar.current
        let currentDate = date(for: field)
        guard let updatedDate = calendar.date(bySetting: .second, value: segundo, of: currentDate) else {
            return
        }
        setDate(updatedDate, for: field)
    }

    func salvar(using modelContext: ModelContext) throws {
        ponto.entrada = hasEntrada ? draftEntrada : nil
        ponto.idaAlmoco = hasIdaAlmoco ? draftIdaAlmoco : nil
        ponto.voltaAlmoco = hasVoltaAlmoco ? draftVoltaAlmoco : nil
        ponto.fimExpediente = hasFimExpediente ? draftFimExpediente : nil

        try modelContext.save()
    }

    private func date(for field: PontoHorarioField) -> Date {
        switch field {
        case .entrada:
            return draftEntrada
        case .idaAlmoco:
            return draftIdaAlmoco
        case .voltaAlmoco:
            return draftVoltaAlmoco
        case .fimExpediente:
            return draftFimExpediente
        }
    }

    private func setDate(_ date: Date, for field: PontoHorarioField) {
        switch field {
        case .entrada:
            draftEntrada = date
        case .idaAlmoco:
            draftIdaAlmoco = date
        case .voltaAlmoco:
            draftVoltaAlmoco = date
        case .fimExpediente:
            draftFimExpediente = date
        }
    }
}
