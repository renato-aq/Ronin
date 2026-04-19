import SwiftData
import SwiftUI

struct EmpresasView: View {
    @AppStorage(PrivacyMode.appStorageKey) private var isPrivacyEnabled = false
    @Query(sort: \Empresa.nome) private var empresas: [Empresa]
    @State private var viewModel = EmpresasViewModel()

    init() {}

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasEmpresa, let row = viewModel.rows.first {
                    List {
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
                                Text(PrivacyMode.display(row.valorHora, isEnabled: isPrivacyEnabled))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    ContentUnavailableView {
                        Label("Cadastre sua empresa", systemImage: "building.2.crop.circle")
                    } description: {
                        Text("Nesta primeira versão do app, você gerencia uma única empresa.")
                    } actions: {
                        Button("Cadastrar Empresa") {
                            viewModel.abrirCriacao()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Empresa")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PrivacyToolbarButton()
                }
                if !viewModel.hasEmpresa {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.abrirCriacao()
                        } label: {
                            Label("Nova Empresa", systemImage: "plus")
                        }
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
