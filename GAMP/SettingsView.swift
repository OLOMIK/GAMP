import SwiftUI

struct SettingsView: View {
    @Environment(ServicesViewModel.self) var viewModel

    @State private var apachePort: String = "8080"
    @State private var mysqlPort: String = "3306"

    @State private var newDomain: String = ""
    @State private var selectedFolder: String = ""
    @State private var htdocsFolders: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("GAMP Console Pro").font(.system(size: 32, weight: .black, design: .rounded))
                        Text("Centrum dowodzenia Twoim lokalnym ekosystemem").foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.bottom, 10)


                SettingsCard(title: "Engine Core", icon: "cpu.fill", color: .green) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Wybierz wersję silnika PHP dla swoich projektów.")
                            .font(.caption).foregroundStyle(.secondary)
                        
                        Picker("Wersja PHP", selection: Binding(
                            get: { viewModel.currentPHPVersion },
                            set: { viewModel.switchPHPVersion(to: $0) }
                        )) {
                            ForEach(viewModel.availablePHPVersions, id: \.self) { version in
                                Text("PHP \(version)").tag(version)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }


                SettingsCard(title: "Magic Domains", icon: "wand.and.stars", color: .purple) {
                    VStack(spacing: 15) {
                        VStack(spacing: 8) {
                            DomainRow(domain: "pma.test", folder: "system/phpmyadmin", isSystem: true) {}
                            
                            ForEach(viewModel.magicDomains) { domain in
                                DomainRow(domain: domain.domainName, folder: domain.folderName, isSystem: false) {
                                    viewModel.magicDomains.removeAll(where: { $0.id == domain.id })
                                }
                            }
                        }
                        
                        Divider().padding(.vertical, 5)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Dodaj nową domenę").font(.caption.bold())
                            HStack {
                                TextField("np. projekt.test", text: $newDomain)
                                    .textFieldStyle(.roundedBorder)
                                
                                Picker("", selection: $selectedFolder) {
                                    Text("Wybierz folder").tag("")
                                    ForEach(htdocsFolders, id: \.self) { Text($0).tag($0) }
                                }
                                .frame(width: 150)
                                
                                Button(action: addDomain) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .disabled(newDomain.isEmpty || selectedFolder.isEmpty)
                            }
                        }
                        
                        Button("Czaruj Domeny (Zastosuj VHosts)") {
                            viewModel.updateMagicDomains()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .frame(maxWidth: .infinity)
                    }
                }


                SettingsCard(title: "Konfiguracja Sieci", icon: "network", color: .blue) {
                    VStack(spacing: 15) {
                        HStack {
                            Label("Port Apache", systemImage: "server.rack")
                            Spacer()
                            TextField("", text: $apachePort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack {
                            Label("Port MySQL", systemImage: "externaldrive.fill")
                            Spacer()
                            TextField("", text: $mysqlPort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Zapisz porty i zrestartuj") {
                            savePorts()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }

                SettingsCard(title: "Narzędzia i diagnostyka", icon: "wrench.and.screwdriver.fill", color: .orange) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Naprawa integracji PHP")
                            .font(.headline)
                        Text("Jeśli Apache nie interpretuje plików .php, użyj tego przycisku, aby naprawić plik httpd.conf.")
                            .font(.caption).foregroundStyle(.secondary)
                        
                        Button(action: { viewModel.configureApacheForPHP() }) {
                            Label("Napraw konfigurację PHP", systemImage: "bolt.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                }


                SettingsCard(title: "Informacje o środowisku", icon: "folder.fill", color: .gray) {
                    VStack(spacing: 12) {
                        InfoRow(label: "Homebrew", value: viewModel.brewPrefix)
                        InfoRow(label: "Htdocs", value: viewModel.htdocsPath)
                        InfoRow(label: "HTTPD Conf", value: viewModel.httpdConfPath)
                    }
                }


                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                        Text("Strefa Nuklearna")
                    }
                    .font(.headline).foregroundStyle(.red)
                    
                    Text("Deinstalacja usuwa binarne pliki serwerów i Twoje lokalne bazy danych MySQL. Folder htdocs zostanie nienaruszony.")
                        .font(.caption).foregroundStyle(.secondary)
                    
                    Button(role: .destructive) {
                        confirmUninstall()
                    } label: {
                        Label("Odinstaluj wszystko i wyczyść system", systemImage: "trash.slash.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(20)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.2), lineWidth: 1))
            }
            .padding(40)
        }
        .onAppear {
            loadHtdocsFolders()
        }
    }


    func addDomain() {
        let domain = MagicDomain(domainName: newDomain, folderName: selectedFolder)
        viewModel.magicDomains.append(domain)
        newDomain = ""
        selectedFolder = ""
    }

    func loadHtdocsFolders() {
        let url = URL(fileURLWithPath: viewModel.htdocsPath)
        if let folders = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey]) {
            htdocsFolders = folders.filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false }
                                   .map { $0.lastPathComponent }
                                   .filter { $0 != "phpmyadmin" }
        }
    }

    func savePorts() {
        let command = "sed -i '' 's/Listen [0-9]*/Listen \(apachePort)/' \(viewModel.httpdConfPath)"
        TerminalHelper.run(command)
        viewModel.toggleApache() 
        viewModel.toggleApache()
    }

    func confirmUninstall() {
        let alert = NSAlert()
        alert.messageText = "Czy na pewno?"
        alert.informativeText = "Usuniesz wszystkie pakiety i bazy danych. Tej operacji nie da się cofnąć."
        alert.addButton(withTitle: "Odinstaluj")
        alert.addButton(withTitle: "Anuluj")
        if alert.runModal() == .alertFirstButtonReturn {
            viewModel.uninstallFullStack()
        }
    }
}


struct SettingsCard<Content: View>: View {
    var title: String
    var icon: String
    var color: Color
    var content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct DomainRow: View {
    var domain: String
    var folder: String
    var isSystem: Bool
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSystem ? "lock.fill" : "globe")
                .foregroundStyle(isSystem ? .secondary : Color.blue)
            Text(domain).font(.system(.body, design: .monospaced))
            Spacer()
            Text(folder).font(.caption).foregroundStyle(.secondary)
            if !isSystem {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct InfoRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label).font(.caption.bold()).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.system(.caption2, design: .monospaced))
            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(value, forType: .string)
            }) {
                Image(systemName: "doc.on.doc").font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(Color.black.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
