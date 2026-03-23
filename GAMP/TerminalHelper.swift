import Foundation

struct TerminalHelper {

    @discardableResult
    static func run(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; \(command)"]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
    

    static func runAndStream(_ command: String, onOutput: @escaping (String) -> Void) {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; \(command)"]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty, let str = String(data: data, encoding: .utf8) {
                // Wysyłamy nowy tekst do UI
                DispatchQueue.main.async { onOutput(str) }
            }
        }
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            DispatchQueue.main.async { onOutput("\nBŁĄD: \(error.localizedDescription)\n") }
        }
        

        fileHandle.readabilityHandler = nil
    }
    
    static func runInTerminal(_ command: String) {
        let script = """
        tell application "Terminal"
            activate
            do script "\(command)"
        end tell
        """
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }
}
