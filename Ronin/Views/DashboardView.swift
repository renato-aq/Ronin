import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Empresa.nome) private var empresas: [Empresa]
    @Query(sort: \PontoDiario.dataReferencia, order: .reverse) private var pontos: [PontoDiario]

    @State private var viewModel = DashboardViewModel()

    private var empresaSelecionada: Empresa? {
        viewModel.empresaSelecionada
    }

    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    resumoFinanceiro

                    if !viewModel.hasEmpresas {
                        emptyState
                    } else {
                        seletorEmpresa
                        resumoDia
                        gradePonto
                    }
                }
                .padding()
            }
            .navigationTitle("Ronin")
            .sheet(isPresented: Binding(
                get: { viewModel.isShowingEmpresaSheet },
                set: { viewModel.isShowingEmpresaSheet = $0 }
            )) {
                EmpresaFormView(mode: .create)
            }
            .task(id: snapshotKey) {
                viewModel.update(empresas: empresas, pontos: pontos)
            }
        }
    }

    private var snapshotKey: String {
        let empresasKey = empresas.map { "\($0.id.uuidString)-\($0.nome)-\($0.valorHoraAtual)" }.joined(separator: "|")
        let pontosKey = pontos.map { "\($0.id.uuidString)-\($0.dataReferencia.timeIntervalSince1970)-\($0.totalHorasTrabalhadas)" }.joined(separator: "|")
        return "\(empresasKey)#\(pontosKey)"
    }

    private var resumoFinanceiro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Valor a Receber no Mês")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(viewModel.totalMesAtualText)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Soma de todas as horas registradas no mês atual.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.16), Color.green.opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Cadastre sua primeira empresa", systemImage: "building.2.crop.circle")
        } description: {
            Text("Você precisa de uma empresa ativa para começar a bater ponto.")
        } actions: {
            Button("Nova Empresa") {
                viewModel.abrirCriacaoEmpresa()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var seletorEmpresa: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Empresa do dia")
                .font(.headline)

            Picker("Empresa", selection: Binding(
                get: { viewModel.selectedEmpresaID },
                set: { viewModel.selecionarEmpresa(id: $0) }
            )) {
                ForEach(viewModel.empresaOptions) { empresa in
                    Text(empresa.nome).tag(empresa.id)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let valorHoraSelecionadoText = viewModel.valorHoraSelecionadoText {
                Text("Valor/hora atual: \(valorHoraSelecionadoText)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var resumoDia: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hoje")
                    .font(.headline)
                Spacer()
                Text(viewModel.resumoDia?.status ?? PontoStatus.naoIniciado.titulo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let resumoDia = viewModel.resumoDia {
                Group {
                    infoRow(titulo: "Empresa", valor: resumoDia.empresa)
                    infoRow(titulo: "Horas", valor: resumoDia.horas)
                    infoRow(titulo: "Entrada", valor: resumoDia.entrada)
                    infoRow(titulo: "Ida almoço", valor: resumoDia.idaAlmoco)
                    infoRow(titulo: "Volta almoço", valor: resumoDia.voltaAlmoco)
                    infoRow(titulo: "Fim", valor: resumoDia.fim)
                }
            } else {
                Text("Nenhum ponto registrado hoje.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var gradePonto: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(viewModel.actionCards) { card in
                Button {
                    do {
                        try viewModel.registrar(evento: card.evento, modelContext: modelContext)
                    } catch {
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: card.evento.symbolName)
                            .font(.system(size: 26))
                        Text(card.evento.titulo)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                        Text(card.descricao)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                    .padding(18)
                }
                .buttonStyle(.plain)
                .background(cardColor(for: card))
                .foregroundStyle(foregroundColor(for: card))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .opacity(card.isEnabled ? 1 : 0.45)
                .disabled(!card.isEnabled)
            }
        }
    }

    private func cardColor(for card: DashboardActionCard) -> some ShapeStyle {
        if card.isHighlighted {
            return AnyShapeStyle(LinearGradient(
                colors: [Color.blue, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
        return AnyShapeStyle(Color(.secondarySystemBackground))
    }

    private func foregroundColor(for card: DashboardActionCard) -> Color {
        card.isHighlighted ? .white : .primary
    }

    private func infoRow(titulo: String, valor: String) -> some View {
        HStack {
            Text(titulo)
                .foregroundStyle(.secondary)
            Spacer()
            Text(valor)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
