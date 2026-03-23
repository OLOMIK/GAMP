import SwiftUI

struct MainView: View {
    @Environment(ServicesViewModel.self) var viewModel
    @State private var selectedTab: String = "Dashboard"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                Label("Strona główna", systemImage: "gauge.with.dots.needle.bottom.100percent")
                    .tag("Dashboard")
                Label("Pliki", systemImage: "folder.fill")
                    .tag("Htdocs")
                Label("Ustawienia", systemImage: "gearshape.fill")
                    .tag("Settings")
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            ZStack {
               
                LinearGradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                if !viewModel.isHomebrewInstalled {
                    MissingHomebrewView()
                } else {
                    switch selectedTab {
                    case "Dashboard": DashboardView()
                    case "Htdocs": HtdocsView()
                    case "Settings": SettingsView()
                    default: DashboardView()
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 500)
    }
}
