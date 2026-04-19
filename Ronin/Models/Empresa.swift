import Foundation
import SwiftData

@Model
final class Empresa {
    @Attribute(.unique) var id: UUID
    var nome: String
    var valorHoraAtual: Double
    var criadaEm: Date

    init(
        id: UUID = UUID(),
        nome: String,
        valorHoraAtual: Double,
        criadaEm: Date = .now
    ) {
        self.id = id
        self.nome = nome
        self.valorHoraAtual = valorHoraAtual
        self.criadaEm = criadaEm
    }
}
