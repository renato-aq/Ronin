import SwiftData
import SwiftUI

struct EmpresasView: View {
    @Query(sort: \Empresa.nome) private var empresas: [Empresa]
    @State private var viewModel = EmpresasViewModel()

    init() {}

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.rows) { row in
                    Button {
                        viewModel.editar(row.empresa)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.nome)
                                    .font(.headline)
                                Text("Criada em \(row.criadaEm)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(row.valorHora)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Empresas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.abrirCriacao()
                    } label: {
                        Label("Nova Empresa", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.isShowingCreateSheet },
                set: { viewModel.isShowingCreateSheet = $0 }
            )) {
                EmpresaFormView(mode: .create)
            }
            .sheet(item: Binding(
                get: { viewModel.empresaEmEdicao },
                set: { viewModel.empresaEmEdicao = $0 }
            )) { empresa in
                EmpresaFormView(mode: .edit(empresa))
            }
            .task(id: snapshotKey) {
                viewModel.update(empresas: empresas)
            }
        }
    }

    private var snapshotKey: String {
        empresas.map { "\($0.id.uuidString)-\($0.nome)-\($0.valorHoraAtual)" }.joined(separator: "|")
    }
}
