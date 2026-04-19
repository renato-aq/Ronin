import SwiftData
import SwiftUI

struct PontoDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PontoDetailViewModel

    init(ponto: PontoDiario) {
        _viewModel = State(initialValue: PontoDetailViewModel(ponto: ponto))
    }

    var body: some View {
        Form {
            Section("Resumo") {
                labeledText("Data", viewModel.dataFormatada)
                labeledText("Empresa", viewModel.nomeEmpresa)
                labeledText("Valor/hora aplicado", viewModel.valorHoraAplicadoFormatado)
                labeledText("Horas calculadas", viewModel.horasCalculadas)
                labeledText("Faturado no dia", viewModel.valorFaturadoFormatado)
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
        .navigationTitle("Detalhe do Dia")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Salvar") {
                    do {
                        try viewModel.salvar(using: modelContext)
                    } catch {
                    }
                }
            }
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
