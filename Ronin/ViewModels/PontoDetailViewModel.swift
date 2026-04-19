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
    private let service = PontoTrackingService()

    let ponto: PontoDiario
    let isNew: Bool

    var draftDataReferencia: Date
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
        isNew = ponto.modelContext == nil

        let baseDate = ponto.dataReferencia
        draftDataReferencia = baseDate
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
        draftDataReferencia.formatted(.dateTime.day().month(.wide).year())
    }

    var navigationTitle: String {
        isNew ? "Novo Registro Manual" : "Detalhe do Dia"
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
        let dataReferencia = Calendar.current.startOfDay(for: draftDataReferencia)
        let pontosExistentes = try modelContext.fetch(FetchDescriptor<PontoDiario>())

        guard !service.hasRegistro(on: dataReferencia, in: pontosExistentes, excluding: ponto.id) else {
            throw PontoTrackingError.duplicateDayRecord
        }

        try validateChronologicalOrder()

        ponto.dataReferencia = dataReferencia
        ponto.entrada = hasEntrada ? draftEntrada : nil
        ponto.idaAlmoco = hasIdaAlmoco ? draftIdaAlmoco : nil
        ponto.voltaAlmoco = hasVoltaAlmoco ? draftVoltaAlmoco : nil
        ponto.fimExpediente = hasFimExpediente ? draftFimExpediente : nil

        if ponto.modelContext == nil {
            modelContext.insert(ponto)
        }

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

    private func validateChronologicalOrder() throws {
        let entrada = hasEntrada ? draftEntrada : nil
        let idaAlmoco = hasIdaAlmoco ? draftIdaAlmoco : nil
        let voltaAlmoco = hasVoltaAlmoco ? draftVoltaAlmoco : nil
        let fimExpediente = hasFimExpediente ? draftFimExpediente : nil

        if idaAlmoco != nil && entrada == nil {
            throw PontoTrackingError.invalidChronologicalOrder(message: "A ida para almoço não pode existir sem o primeiro ponto de entrada.")
        }

        if voltaAlmoco != nil && idaAlmoco == nil {
            throw PontoTrackingError.invalidChronologicalOrder(message: "A volta do almoço não pode existir sem a ida para almoço.")
        }

        if fimExpediente != nil && entrada == nil {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O fim do expediente não pode existir sem o primeiro ponto de entrada.")
        }

        if let entrada, let idaAlmoco, idaAlmoco < entrada {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O segundo ponto não pode ser antes do primeiro ponto.")
        }

        if let idaAlmoco, let voltaAlmoco, voltaAlmoco < idaAlmoco {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O terceiro ponto não pode ser antes do segundo ponto.")
        }

        if let entrada, let voltaAlmoco, voltaAlmoco < entrada {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O terceiro ponto não pode ser antes do primeiro ponto.")
        }

        if let entrada, let fimExpediente, fimExpediente < entrada {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O quarto ponto não pode ser antes do primeiro ponto.")
        }

        if let idaAlmoco, let fimExpediente, fimExpediente < idaAlmoco {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O quarto ponto não pode ser antes do segundo ponto.")
        }

        if let voltaAlmoco, let fimExpediente, fimExpediente < voltaAlmoco {
            throw PontoTrackingError.invalidChronologicalOrder(message: "O quarto ponto não pode ser antes do terceiro ponto.")
        }
    }
}
