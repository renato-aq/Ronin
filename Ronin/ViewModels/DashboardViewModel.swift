import Foundation
import Observation
import SwiftData

struct DashboardResumoDia {
    let status: String
    let empresa: String
    let horas: String
    let entrada: String
    let idaAlmoco: String
    let voltaAlmoco: String
    let fim: String
}

struct DashboardActionCard: Identifiable, Equatable {
    let id: PontoEvento
    let evento: PontoEvento
    let descricao: String
    let isEnabled: Bool
    let isHighlighted: Bool
}

@Observable
final class DashboardViewModel {
    private let service = PontoTrackingService()

    private(set) var empresas: [Empresa] = []
    private(set) var pontos: [PontoDiario] = []

    var totalMesAtualText = 0.0.formatted(RoninFormatters.currencyBRL)
    var resumoDia: DashboardResumoDia?
    var actionCards: [DashboardActionCard] = []
    var hasEmpresas = false
    var isShowingEmpresaSheet = false

    func update(empresas: [Empresa], pontos: [PontoDiario]) {
        self.empresas = empresas
        self.pontos = pontos

        hasEmpresas = !empresas.isEmpty
        totalMesAtualText = service.totalMesAtual(from: pontos).formatted(RoninFormatters.currencyBRL)
        resumoDia = buildResumoDia()
        actionCards = buildActionCards()
    }

    var empresaSelecionada: Empresa? {
        empresas.first
    }

    func abrirCriacaoEmpresa() {
        isShowingEmpresaSheet = true
    }

    func fecharCriacaoEmpresa() {
        isShowingEmpresaSheet = false
    }

    func registrar(evento: PontoEvento, modelContext: ModelContext) throws {
        let pontoAtualizado = try service.registrar(
            evento: evento,
            empresa: empresaSelecionada,
            pontos: pontos,
            modelContext: modelContext
        )

        var pontosAtualizados = pontos
        if let index = pontosAtualizados.firstIndex(where: { $0.id == pontoAtualizado.id }) {
            pontosAtualizados[index] = pontoAtualizado
        } else {
            pontosAtualizados.insert(pontoAtualizado, at: 0)
        }

        update(empresas: empresas, pontos: pontosAtualizados)
    }

    private func buildResumoDia() -> DashboardResumoDia? {
        guard let pontoHoje = service.pontoDoDia(from: pontos) else {
            return nil
        }

        return DashboardResumoDia(
            status: pontoHoje.status.titulo,
            empresa: pontoHoje.nomeEmpresaSnapshot,
            horas: RoninFormatters.horas(pontoHoje.totalHorasTrabalhadas),
            entrada: hora(pontoHoje.entrada),
            idaAlmoco: hora(pontoHoje.idaAlmoco),
            voltaAlmoco: hora(pontoHoje.voltaAlmoco),
            fim: hora(pontoHoje.fimExpediente)
        )
    }

    private func buildActionCards() -> [DashboardActionCard] {
        let pontoHoje = service.pontoDoDia(from: pontos)
        let proximoEvento = pontoHoje?.proximoEventoPermitido ?? .entrada

        return PontoEvento.allCases.map { evento in
            let isEnabled: Bool
            if !hasEmpresas {
                isEnabled = false
            } else if evento == .entrada {
                isEnabled = proximoEvento == .entrada && empresaSelecionada != nil
            } else {
                isEnabled = proximoEvento == evento
            }

            let descricao: String
            if proximoEvento == evento {
                descricao = "Próxima ação disponível"
            } else if pontoHoje?.proximoEventoPermitido == nil, pontoHoje != nil {
                descricao = "Dia encerrado"
            } else {
                descricao = "Aguardando etapa anterior"
            }

            return DashboardActionCard(
                id: evento,
                evento: evento,
                descricao: descricao,
                isEnabled: isEnabled,
                isHighlighted: proximoEvento == evento
            )
        }
    }

    private func hora(_ date: Date?) -> String {
        guard let date else { return "--:--" }
        return date.formatted(RoninFormatters.hourMinuteSecond)
    }
}
