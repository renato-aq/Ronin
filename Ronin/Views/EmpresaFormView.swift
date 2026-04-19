import SwiftData
import SwiftUI

enum EmpresaFormMode {
    case create
    case edit(Empresa)
}

struct EmpresaFormView: View {
    private enum Field {
        case valorHora
    }

    @AppStorage(PrivacyMode.appStorageKey) private var isPrivacyEnabled = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EmpresaFormViewModel
    @State private var valorHoraText: String
    @State private var shouldClearValorHoraOnFocus: Bool
    @FocusState private var focusedField: Field?

    let mode: EmpresaFormMode

    init(mode: EmpresaFormMode) {
        self.mode = mode
        let viewModel = EmpresaFormViewModel(mode: mode)
        _viewModel = State(initialValue: viewModel)
        _valorHoraText = State(initialValue: RoninFormatters.decimalInput(viewModel.valorHora))
        _shouldClearValorHoraOnFocus = State(initialValue: !RoninFormatters.decimalInput(viewModel.valorHora).isEmpty)
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

                    if isPrivacyEnabled {
                        LabeledContent("Valor/Hora", value: PrivacyMode.maskedValue)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("R$")
                                    .foregroundStyle(.secondary)
                                TextField("Valor/Hora", text: $valorHoraText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .valorHora)
                            }
                            if let mensagemErro = viewModel.valorHoraMensagemErro(valorHoraText) {
                                Text(mensagemErro)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }
                        .onChange(of: focusedField) { _, newValue in
                            guard newValue == .valorHora, shouldClearValorHoraOnFocus else { return }
                            valorHoraText = ""
                            viewModel.valorHora = 0
                            shouldClearValorHoraOnFocus = false
                        }
                        .onChange(of: valorHoraText) { _, newValue in
                            let sanitizedValue = RoninFormatters.sanitizeCurrencyInput(newValue)
                            if sanitizedValue != newValue {
                                valorHoraText = sanitizedValue
                                return
                            }
                            viewModel.valorHora = RoninFormatters.parseDecimalInput(sanitizedValue) ?? 0
                        }
                    }
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
                    PrivacyToolbarButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        salvar()
                    }
                    .disabled(!viewModel.formValido(valorHoraText: valorHoraText))
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
