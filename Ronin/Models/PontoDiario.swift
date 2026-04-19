import Foundation
import SwiftData

enum PontoEvento: String, CaseIterable, Identifiable {
    case entrada
    case idaAlmoco
    case voltaAlmoco
    case fimExpediente

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .entrada:
            "Entrada"
        case .idaAlmoco:
            "Ida para Almoço"
        case .voltaAlmoco:
            "Volta do Almoço"
        case .fimExpediente:
            "Fim Expediente"
        }
    }

    var symbolName: String {
        switch self {
        case .entrada:
            "play.circle.fill"
        case .idaAlmoco:
            "pause.circle.fill"
        case .voltaAlmoco:
            "play.circle"
        case .fimExpediente:
            "stop.circle.fill"
        }
    }
}

enum PontoStatus: String {
    case naoIniciado
    case emAndamento
    case emAlmoco
    case retornado
    case completo
    case incompleto

    var titulo: String {
        switch self {
        case .naoIniciado:
            "Não iniciado"
        case .emAndamento:
            "Em andamento"
        case .emAlmoco:
            "Em almoço"
        case .retornado:
            "Retornado"
        case .completo:
            "Completo"
        case .incompleto:
            "Pendente"
        }
    }
}

@Model
final class PontoDiario {
    @Attribute(.unique) var id: UUID
    var dataReferencia: Date
    var entrada: Date?
    var idaAlmoco: Date?
    var voltaAlmoco: Date?
    var fimExpediente: Date?
    var empresaID: UUID?
    var nomeEmpresaSnapshot: String
    var valorHoraAplicado: Double

    init(
        id: UUID = UUID(),
        dataReferencia: Date,
        entrada: Date? = nil,
        idaAlmoco: Date? = nil,
        voltaAlmoco: Date? = nil,
        fimExpediente: Date? = nil,
        empresaID: UUID? = nil,
        nomeEmpresaSnapshot: String = "",
        valorHoraAplicado: Double = 0
    ) {
        self.id = id
        self.dataReferencia = dataReferencia
        self.entrada = entrada
        self.idaAlmoco = idaAlmoco
        self.voltaAlmoco = voltaAlmoco
        self.fimExpediente = fimExpediente
        self.empresaID = empresaID
        self.nomeEmpresaSnapshot = nomeEmpresaSnapshot
        self.valorHoraAplicado = valorHoraAplicado
    }

    var status: PontoStatus {
        if entrada == nil, idaAlmoco == nil, voltaAlmoco == nil, fimExpediente == nil {
            return .naoIniciado
        }
        if entrada != nil, idaAlmoco == nil, voltaAlmoco == nil, fimExpediente == nil {
            return .emAndamento
        }
        if entrada != nil, idaAlmoco != nil, voltaAlmoco == nil, fimExpediente == nil {
            return .emAlmoco
        }
        if entrada != nil, idaAlmoco != nil, voltaAlmoco != nil, fimExpediente == nil {
            return .retornado
        }
        if entrada != nil, fimExpediente != nil {
            if idaAlmoco == nil, voltaAlmoco == nil {
                return .completo
            }
            if idaAlmoco != nil, voltaAlmoco != nil {
                return .completo
            }
        }
        return .incompleto
    }

    var proximoEventoPermitido: PontoEvento? {
        if entrada == nil { return .entrada }
        if idaAlmoco == nil { return .idaAlmoco }
        if voltaAlmoco == nil { return .voltaAlmoco }
        if fimExpediente == nil { return .fimExpediente }
        return nil
    }

    var totalHorasTrabalhadas: TimeInterval {
        if let entrada, let fimExpediente, idaAlmoco == nil, voltaAlmoco == nil {
            return max(0, fimExpediente.timeIntervalSince(entrada))
        }

        var total: TimeInterval = 0
        if let entrada, let idaAlmoco {
            total += max(0, idaAlmoco.timeIntervalSince(entrada))
        }
        if let voltaAlmoco, let fimExpediente {
            total += max(0, fimExpediente.timeIntervalSince(voltaAlmoco))
        }
        return total
    }

    var valorFaturadoDia: Double {
        (totalHorasTrabalhadas / 3600) * valorHoraAplicado
    }
}
