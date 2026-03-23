import SwiftUI

@main
struct GAMPApp: App {
    @State private var viewModel = ServicesViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(viewModel)
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}


struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

