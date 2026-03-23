import SwiftUI

struct DashboardView: View {
    @Environment(ServicesViewModel.self) var viewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Lokalne Środowisko")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.top, 30)
            
            if viewModel.isBusy {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .controlSize(.large)
                                Text(viewModel.busyMessage)
                                    .font(.headline)
                                    .foregroundStyle(viewModel.showCloseButton ? .red : .secondary) // Zmieni kolor na czerwony jak będzie błąd
                                
                                ScrollViewReader { proxy in
                                    ScrollView {
                                        Text(viewModel.installLog)
                                            .font(.system(.caption, design: .monospaced))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .id("bottomOfLog")
                                    }
                                    .frame(height: 250)
                                    .padding()
                                    .background(Color.black.opacity(0.85))
                                    .foregroundStyle(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .onChange(of: viewModel.installLog) { _, _ in
                                        withAnimation { proxy.scrollTo("bottomOfLog", anchor: .bottom) }
                                    }
                                }
                                

                                if viewModel.showCloseButton {
                                    Button("Zamknij konsolę") {
                                        viewModel.isBusy = false
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                }

                                
                            }
                            .padding(.horizontal, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if !viewModel.isStackInstalled {
                VStack(spacing: 15) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    
                    Text("Brak wymaganych komponentów")
                        .font(.title2.bold())
                    
                    Text("Aplikacja musi zainstalować Apache, MySQL, PHP oraz phpMyAdmin. Potrwa to kilka minut, proces odbędzie się w tle.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 40)
                    
                    Button("Zainstaluj środowisko GAMP") {
                        viewModel.installFullStack()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, 10)
                }
                .padding(40)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 40)
                Spacer()
                
            } else {

                HStack(spacing: 25) {
                    ServiceCard(
                        title: "Apache",
                        icon: "globe",
                        color: .blue,
                        isRunning: viewModel.isApacheRunning,
                        action: { viewModel.toggleApache() }
                    )
                    
                    ServiceCard(
                        title: "MySQL",
                        icon: "cylinder.split.1x2",
                        color: .orange,
                        isRunning: viewModel.isMySQLRunning,
                        action: { viewModel.toggleMySQL() }
                    )
                }
                .padding(.horizontal, 40)
                

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Narzędzia")
                            .font(.headline)
                        Text("Szybki dostęp do localhosta")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    
                    Button("Otwórz Localhost") {
                        NSWorkspace.shared.open(URL(string: "http://localhost:8080")!)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("phpMyAdmin") {
                        NSWorkspace.shared.open(URL(string: "http://localhost:8080/phpmyadmin")!)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}


struct ServiceCard: View {
    var title: String
    var icon: String
    var color: Color
    var isRunning: Bool
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(color)
                    .symbolEffect(.pulse, isActive: isRunning)
                
                Spacer()
                
                Circle()
                    .fill(isRunning ? Color.green : Color.gray.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .shadow(color: isRunning ? .green : .clear, radius: 5)
            }
            
            Text(title)
                .font(.title2.bold())
            
            Toggle("", isOn: Binding(
                get: { isRunning },
                set: { _ in action() }
            ))
            .toggleStyle(.switch)
            .tint(color)
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
