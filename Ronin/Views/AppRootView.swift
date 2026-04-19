import SwiftUI

struct AppRootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            HistoricoView()
                .tabItem {
                    Label("Histórico", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }

            EmpresasView()
                .tabItem {
                    Label("Empresas", systemImage: "building.2.fill")
                }
        }
    }
}
