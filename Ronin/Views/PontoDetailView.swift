import SwiftData
import SwiftUI

struct PontoDetailView: View {
    @AppStorage(PrivacyMode.appStorageKey) private var isPrivacyEnabled = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PontoDetailViewModel
    @State private var errorMessage: String?

    init(ponto: PontoDiario) {
        _viewModel = State(initialValue: PontoDetailViewModel(ponto: ponto))
    }

    var body: some View {
        Form {
            Section("Resumo") {
                DatePicker(
                    "Data",
                    selection: Binding(
                        get: { viewModel.draftDataReferencia },
                        set: { viewModel.draftDataReferencia = $0 }
                    ),
                    displayedComponents: [.date]
                )
                labeledText("Empresa", viewModel.nomeEmpresa)
                labeledText("Valor/hora aplicado", PrivacyMode.display(viewModel.valorHoraAplicadoFormatado, isEnabled: isPrivacyEnabled))
                labeledText("Horas calculadas", viewModel.horasCalculadas)
                labeledText("Faturado no dia", PrivacyMode.display(viewModel.valorFaturadoFormatado, isEnabled: isPrivacyEnabled))
            }

            Section("Horários") {
                optionalDatePicker(
                    "Entrada",
                    hasValue: Binding(get: { viewModel.hasEntrada }, set: { viewModel.hasEntrada = $0 }),
                    value: Binding(get: { viewModel.draftEntrada }, set: { viewModel.draftEntrada = $0 }),
                    field: .entrada
                )
                optionalDatePicker(
                    "Ida para Almoço",
                    hasValue: Binding(get: { viewModel.hasIdaAlmoco }, set: { viewModel.hasIdaAlmoco = $0 }),
                    value: Binding(get: { viewModel.draftIdaAlmoco }, set: { viewModel.draftIdaAlmoco = $0 }),
                    field: .idaAlmoco
                )
                optionalDatePicker(
                    "Volta do Almoço",
                    hasValue: Binding(get: { viewModel.hasVoltaAlmoco }, set: { viewModel.hasVoltaAlmoco = $0 }),
                    value: Binding(get: { viewModel.draftVoltaAlmoco }, set: { viewModel.draftVoltaAlmoco = $0 }),
                    field: .voltaAlmoco
                )
                optionalDatePicker(
                    "Fim Expediente",
                    hasValue: Binding(get: { viewModel.hasFimExpediente }, set: { viewModel.hasFimExpediente = $0 }),
                    value: Binding(get: { viewModel.draftFimExpediente }, set: { viewModel.draftFimExpediente = $0 }),
                    field: .fimExpediente
                )
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.isNew {
                    Button("Cancelar") {
                        dismiss()
                    }
                } else {
                    PrivacyToolbarButton()
                }
            }
            ToolbarItem(placement: .principal) {
                if viewModel.isNew {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isNew {
                    PrivacyToolbarButton()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Salvar") {
                    do {
                        try viewModel.salvar(using: modelContext)
                        if viewModel.isNew {
                            dismiss()
                        }
                    } catch {
                        errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível salvar o registro."
                    }
                }
            }
        }
        .alert("Atenção", isPresented: Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func labeledText(_ titulo: String, _ valor: String) -> some View {
        HStack {
            Text(titulo)
            Spacer()
            Text(valor)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
    }

    private func optionalDatePicker(
        _ title: String,
        hasValue: Binding<Bool>,
        value: Binding<Date>,
        field: PontoHorarioField
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(title, isOn: hasValue)
            if hasValue.wrappedValue {
                DatePicker(
                    title,
                    selection: value,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)

                Picker(
                    "Segundos",
                    selection: Binding(
                        get: { viewModel.segundo(for: field) },
                        set: { viewModel.setSegundo($0, for: field) }
                    )
                ) {
                    ForEach(0..<60, id: \.self) { segundo in
                        Text(String(format: "%02d s", segundo)).tag(segundo)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}
