import SwiftUI
import UniformTypeIdentifiers

struct HtdocsView: View {
    @Environment(ServicesViewModel.self) var viewModel
    @State private var files: [FileItem] = []
    @State private var isHovering = false
    @State private var selectedFile: FileItem?
    @State private var showingNewFolderAlert = false
    @State private var newFolderName = ""
    
    var body: some View {
        VStack(spacing: 0) {

            HStack {
                VStack(alignment: .leading) {
                    Text("Twój folder Htdocs")
                        .font(.title2.bold())
                    Text(viewModel.htdocsPath)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingNewFolderAlert = true }) {
                    Label("Nowy Folder", systemImage: "folder.badge.plus")
                }
                .buttonStyle(.bordered)
                
                Button(action: { refreshFiles() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.ultraThinMaterial)
            

            List(files, selection: $selectedFile) { file in
                HStack(spacing: 12) {
                    Image(nsImage: file.icon)
                        .resizable()
                        .frame(width: 18, height: 18)
                    
                    Text(file.name)
                        .font(.body)
                    
                    Spacer()
                    
                    if file.isDirectory {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    NSWorkspace.shared.open(file.url)
                }
                .contextMenu {
                    Button("Otwórz") { NSWorkspace.shared.open(file.url) }
                    Button("Okaż w Finderze") { NSWorkspace.shared.activateFileViewerSelecting([file.url]) }
                    Divider()
                    Button("Usuń", role: .destructive) { deleteFile(file) }
                }
            }
            .listStyle(.inset)
            .onDeleteCommand {
                if let selected = selectedFile { deleteFile(selected) }
            }
            

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHovering ? Color.blue : Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .background(isHovering ? Color.blue.opacity(0.05) : Color.clear)
                
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Upuść pliki tutaj, aby skopiować do htdocs")
                }
                .foregroundStyle(isHovering ? .blue : .secondary)
            }
            .frame(height: 60)
            .padding()
            .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
                handleDrop(providers: providers)
            }
        }
        .onAppear { refreshFiles() }
        .sheet(isPresented: $showingNewFolderAlert) {
            VStack(spacing: 20) {
                Text("Nowy folder").font(.headline)
                TextField("Nazwa folderu", text: $newFolderName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 250)
                
                HStack {
                    Button("Anuluj") { showingNewFolderAlert = false }
                    Button("Stwórz") { createFolder() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Logika plików
    
    func refreshFiles() {
        let path = viewModel.htdocsPath
        let url = URL(fileURLWithPath: path)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            
            self.files = contents
                .filter { $0.lastPathComponent.lowercased() != "phpmyadmin" } // Ukrywamy phpmyadmin
                .map { url in
                    let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey])
                    return FileItem(
                        url: url,
                        name: url.lastPathComponent,
                        isDirectory: resourceValues?.isDirectory ?? false
                    )
                }
                .sorted { (a, b) in
                    if a.isDirectory != b.isDirectory { return a.isDirectory } // Foldery najpierw
                    return a.name.lowercased() < b.name.lowercased()
                }
        } catch {
            print("Błąd listowania plików: \(error)")
        }
    }
    
    func deleteFile(_ file: FileItem) {
        let alert = NSAlert()
        alert.messageText = "Usunąć \(file.name)?"
        alert.informativeText = "Tego kroku nie da się cofnąć."
        alert.addButton(withTitle: "Usuń")
        alert.addButton(withTitle: "Anuluj")
        
        if alert.runModal() == .alertFirstButtonReturn {
            try? FileManager.default.removeItem(at: file.url)
            refreshFiles()
        }
    }
    
    func createFolder() {
        guard !newFolderName.isEmpty else { return }
        let newFolderUrl = URL(fileURLWithPath: viewModel.htdocsPath).appendingPathComponent(newFolderName)
        
        do {
            try FileManager.default.createDirectory(at: newFolderUrl, withIntermediateDirectories: true)
            newFolderName = ""
            showingNewFolderAlert = false
            refreshFiles()
        } catch {
            print("Błąd tworzenia folderu: \(error)")
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                if let data = item as? Data, let sourceUrl = URL(dataRepresentation: data, relativeTo: nil) {
                    let destinationUrl = URL(fileURLWithPath: viewModel.htdocsPath).appendingPathComponent(sourceUrl.lastPathComponent)
                    
                    do {
                        if FileManager.default.fileExists(atPath: destinationUrl.path) {
                            try FileManager.default.removeItem(at: destinationUrl)
                        }
                        try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
                        
                        DispatchQueue.main.async { refreshFiles() }
                    } catch {
                        print("Błąd kopiowania: \(error)")
                    }
                }
            }
        }
        return true
    }
}
