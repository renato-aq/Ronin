import Foundation
import SwiftData

struct PontoTrackingService {
    func totalMesAtual(
        from pontos: [PontoDiario],
        calendar: Calendar = .current,
        now: Date = .now
    ) -> Double {
        pontos
            .filter { calendar.isDate($0.dataReferencia, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.valorFaturadoDia }
    }

    func pontoDoDia(
        from pontos: [PontoDiario],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> PontoDiario? {
        let startOfDay = calendar.startOfDay(for: now)
        return pontos.first { calendar.startOfDay(for: $0.dataReferencia) == startOfDay }
    }

    @discardableResult
    func registrar(
        evento: PontoEvento,
        empresa: Empresa?,
        pontos: [PontoDiario],
        modelContext: ModelContext,
        now: Date = .now,
        calendar: Calendar = .current
    ) throws -> PontoDiario {
        let startOfDay = calendar.startOfDay(for: now)
        let ponto = pontoDoDia(from: pontos, now: now, calendar: calendar)
            ?? PontoDiario(
                dataReferencia: startOfDay,
                empresaID: empresa?.id,
                nomeEmpresaSnapshot: empresa?.nome ?? "",
                valorHoraAplicado: empresa?.valorHoraAtual ?? 0
            )

        if ponto.modelContext == nil {
            modelContext.insert(ponto)
        }

        if ponto.empresaID == nil, let empresa {
            ponto.empresaID = empresa.id
            ponto.nomeEmpresaSnapshot = empresa.nome
            ponto.valorHoraAplicado = empresa.valorHoraAtual
        }

        switch evento {
        case .entrada where ponto.entrada == nil:
            ponto.entrada = now
        case .idaAlmoco where ponto.entrada != nil && ponto.idaAlmoco == nil:
            ponto.idaAlmoco = now
        case .voltaAlmoco where ponto.idaAlmoco != nil && ponto.voltaAlmoco == nil:
            ponto.voltaAlmoco = now
        case .fimExpediente where ponto.entrada != nil && ponto.fimExpediente == nil:
            ponto.fimExpediente = now
        default:
            break
        }

        try modelContext.save()
        return ponto
    }
}
,
