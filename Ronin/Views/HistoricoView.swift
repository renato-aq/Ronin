import SwiftData
import SwiftUI

struct HistoricoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PontoDiario.dataReferencia, order: .reverse) private var pontos: [PontoDiario]
    @State private var viewModel = HistoricoViewModel()

    init() {}

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.secoes) { secao in
                    Section(secao.titulo.capitalized) {
                        ForEach(secao.rows) { row in
                            NavigationLink {
                                PontoDetailView(ponto: row.ponto)
                            } label: {
                                HistoricoRowView(row: row)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.solicitarExclusao(row.ponto)
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Histórico")
            .task(id: snapshotKey) {
                viewModel.update(pontos: pontos)
            }
            .confirmationDialog(
                "Excluir registro de horas?",
                isPresented: Binding(
                    get: { viewModel.pontoPendenteExclusao != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.cancelarExclusao()
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Excluir", role: .destructive) {
                    guard let ponto = viewModel.pontoPendenteExclusao else { return }
                    do {
                        try viewModel.excluir(ponto, using: modelContext)
                        viewModel.cancelarExclusao()
                    } catch {
                    }
                }
                Button("Cancelar", role: .cancel) {
                    viewModel.cancelarExclusao()
                }
            } message: {
                Text("Essa ação remove permanentemente o registro do histórico.")
            }
        }
    }

    private var snapshotKey: String {
        pontos.map { "\($0.id.uuidString)-\($0.dataReferencia.timeIntervalSince1970)-\($0.totalHorasTrabalhadas)" }.joined(separator: "|")
    }
}

private struct HistoricoRowView: View {
    let row: HistoricoRowData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(row.data)
                    .font(.headline)
                Spacer()
                Text(row.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(row.empresa)
                .font(.subheadline)

            HStack {
                Text(row.horas)
                Spacer()
                Text(row.valor)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
