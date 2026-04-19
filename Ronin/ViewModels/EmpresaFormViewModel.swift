import Foundation
import Observation
import SwiftData

@Observable
final class EmpresaFormViewModel {
    let mode: EmpresaFormMode
    let title: String
    let isEditMode: Bool

    var nome: String
    var valorHora: Double

    init(mode: EmpresaFormMode) {
        self.mode = mode

        switch mode {
        case .create:
            title = "Nova Empresa"
            isEditMode = false
            nome = ""
            valorHora = 0
        case let .edit(empresa):
            title = "Editar Empresa"
            isEditMode = true
            nome = empresa.nome
            valorHora = empresa.valorHoraAtual
        }
    }

    var formValido: Bool {
        let nomeValido = isEditMode || !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return nomeValido && valorHora > 0
    }

    func formValido(valorHoraText: String) -> Bool {
        let nomeValido = isEditMode || !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return nomeValido && RoninFormatters.isValidCurrencyInput(valorHoraText) && valorHora > 0
    }

    func valorHoraMensagemErro(_ valorHoraText: String) -> String? {
        RoninFormatters.currencyValidationMessage(valorHoraText)
    }

    func salvar(using modelContext: ModelContext) throws {
        switch mode {
        case .create:
            let empresa = Empresa(
                nome: nome.trimmingCharacters(in: .whitespacesAndNewlines),
                valorHoraAtual: valorHora
            )
            modelContext.insert(empresa)
        case let .edit(empresa):
            empresa.valorHoraAtual = valorHora
        }

        try modelContext.save()
    }
}
