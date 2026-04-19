import SwiftData
import SwiftUI

@main
struct RoninApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [Empresa.self, PontoDiario.self])
    }
}
