import Foundation
import Observation

struct EmpresaRowData: Identifiable {
    let id: UUID
    let empresa: Empresa
    let nome: String
    let criadaEm: String
    let valorHora: String
}

@Observable
final class EmpresasViewModel {
    var rows: [EmpresaRowData] = []
    var empresaEmEdicao: Empresa?
    var isShowingCreateSheet = false
    var hasEmpresa = false

    func update(empresas: [Empresa]) {
        hasEmpresa = !empresas.isEmpty
        rows = empresas.map { empresa in
            EmpresaRowData(
                id: empresa.id,
                empresa: empresa,
                nome: empresa.nome,
                criadaEm: empresa.criadaEm.formatted(.dateTime.day().month().year()),
                valorHora: empresa.valorHoraAtual.formatted(RoninFormatters.currencyBRL)
            )
        }
    }

    func abrirCriacao() {
        guard !hasEmpresa else { return }
        isShowingCreateSheet = true
    }

    func fecharCriacao() {
        isShowingCreateSheet = false
    }

    func editar(_ empresa: Empresa) {
        empresaEmEdicao = empresa
    }

    func fecharEdicao() {
        empresaEmEdicao = nil
    }
}
