import SwiftData
import SwiftUI

enum EmpresaFormMode {
    case create
    case edit(Empresa)
}

struct EmpresaFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EmpresaFormViewModel

    let mode: EmpresaFormMode

    init(mode: EmpresaFormMode) {
        self.mode = mode
        _viewModel = State(initialValue: EmpresaFormViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dados") {
                    TextField("Nome da Empresa", text: Binding(
                        get: { viewModel.nome },
                        set: { viewModel.nome = $0 }
                    ))
                    .disabled(viewModel.isEditMode)
                    TextField("Valor/Hora", value: Binding(
                        get: { viewModel.valorHora },
                        set: { viewModel.valorHora = $0 }
                    ), format: RoninFormatters.currencyBRL)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        salvar()
                    }
                    .disabled(!viewModel.formValido)
                }
            }
        }
    }

    private func salvar() {
        do {
            try viewModel.salvar(using: modelContext)
            dismiss()
        } catch {
        }
    }
}
