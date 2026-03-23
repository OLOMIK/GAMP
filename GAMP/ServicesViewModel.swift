import SwiftUI
import Observation
import Foundation

struct MagicDomain: Codable, Identifiable {
    var id = UUID()
    var domainName: String
    var folderName: String
}

@Observable
class ServicesViewModel {

    var isHomebrewInstalled: Bool = false
    var isApacheRunning: Bool = false
    var isMySQLRunning: Bool = false
    var isStackInstalled: Bool = false
    

    var isBusy: Bool = false
    var busyMessage: String = ""
    var installLog: String = ""
    var showCloseButton: Bool = false
    

    var availablePHPVersions: [String] = ["8.2", "8.3", "8.4"]
    var currentPHPVersion: String = "8.4"
    

    var magicDomains: [MagicDomain] = [] {
        didSet { saveDomains() }
    }
    

    var brewPrefix: String {
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew") {
            return "/opt/homebrew" // Apple Silicon
        } else if FileManager.default.fileExists(atPath: "/usr/local/bin/brew") {
            return "/usr/local" // Mac Intel
        }
        return "/opt/homebrew"
    }
    
    var brewExe: String { return "\(brewPrefix)/bin/brew" }
    var htdocsPath: String { return "\(brewPrefix)/var/www" }
    var pmaPath: String { return "\(brewPrefix)/var/www/phpmyadmin" }
    var httpdConfPath: String { return "\(brewPrefix)/etc/httpd/httpd.conf" }

    init() {
        loadDomains()
        checkStatus()
    }
    
    // MARK: - SPRAWDZANIE STATUSU
    func checkStatus() {
        isHomebrewInstalled = FileManager.default.fileExists(atPath: brewExe)
        guard isHomebrewInstalled else { return }
        
        let installedFormulae = TerminalHelper.run("\(brewExe) list")
        isStackInstalled = installedFormulae.contains("httpd") && installedFormulae.contains("mysql") && installedFormulae.contains("php")
        
        let services = TerminalHelper.run("\(brewExe) services list")
        isApacheRunning = services.contains("httpd started")
        isMySQLRunning = services.contains("mysql started")
        
        // Wykrywanie aktualnej wersji PHP
        let phpV = TerminalHelper.run("php -v")
        if phpV.contains("PHP 8.2") { currentPHPVersion = "8.2" }
        else if phpV.contains("PHP 8.3") { currentPHPVersion = "8.3" }
        else { currentPHPVersion = "8.4" }
    }

    // MARK: - ENGINE CORE (PHP SWITCHER)
    func switchPHPVersion(to version: String) {
        isBusy = true
        busyMessage = "Przełączanie silnika na PHP \(version)..."
        
        let phpPkg = version == "8.4" ? "php" : "php@\(version)"
        
        let command = """
        # 1. Przełączanie pakietów w Homebrew
        \(brewExe) unlink php php@8.2 php@8.3
        \(brewExe) link --force --overwrite \(phpPkg)
        
        # 2. Aktualizacja biblioteki w httpd.conf
        # Szukamy gdzie leży libphp.so dla tej wersji
        NEW_LIB=$(ls \(brewPrefix)/opt/\(phpPkg)/lib/httpd/modules/libphp*.so | head -n 1)
        if [ -f "$NEW_LIB" ]; then
            sed -i '' "s|LoadModule php_module .*|LoadModule php_module $NEW_LIB|g" "\(httpdConfPath)"
        fi
        
        # 3. Restart wszystkiego
        \(brewExe) services restart httpd
        """
        
        Task {
            await runAsync(command, onOutput: { _ in })
            DispatchQueue.main.async {
                self.checkStatus()
                self.isBusy = false
            }
        }
    }

    // MARK: - MAGIC DOMAINS (VHOSTS)
    func updateMagicDomains() {
        isBusy = true
        busyMessage = "Czarowanie domen (wymaga hasła)..."
        

        var vhostConfig = """
        # --- GAMP MAGIC DOMAINS CONFIG ---
        <VirtualHost *:8080>
            DocumentRoot "\(htdocsPath)"
            ServerName localhost
        </VirtualHost>

        <VirtualHost *:8080>
            DocumentRoot "\(pmaPath)"
            ServerName pma.test
            <Directory "\(pmaPath)">
                AllowOverride All
                Require all granted
            </Directory>
        </VirtualHost>
        """
        
        // Dodawanie domen użytkownika
        var hostsEntries = "127.0.0.1 localhost\\n127.0.0.1 pma.test"
        
        for domain in magicDomains {
            vhostConfig += """
            \n<VirtualHost *:8080>
                DocumentRoot "\(htdocsPath)/\(domain.folderName)"
                ServerName \(domain.domainName)
                <Directory "\(htdocsPath)/\(domain.folderName)">
                    AllowOverride All
                    Require all granted
                </Directory>
            </VirtualHost>
            """
            hostsEntries += "\\n127.0.0.1 \(domain.domainName)"
        }
        
        let vhostFilePath = "\(brewPrefix)/etc/httpd/extra/httpd-vhosts.conf"
        
        let command = """
        # 1. Zapis pliku VHosts
        echo '\(vhostConfig)' > "\(vhostFilePath)"
        
        # 2. Włączenie VHosts w httpd.conf jeśli wyłączone
        sed -i '' 's|^#Include \(brewPrefix)/etc/httpd/extra/httpd-vhosts.conf|Include \(brewPrefix)/etc/httpd/extra/httpd-vhosts.conf|' "\(httpdConfPath)"
        if ! grep -q "httpd-vhosts.conf" "\(httpdConfPath)"; then
            echo "Include \(vhostFilePath)" >> "\(httpdConfPath)"
        fi

        # 3. Aktualizacja systemowego pliku HOSTS
        osascript -e 'do shell script "echo \"\(hostsEntries)\" > /etc/hosts" with administrator privileges'
        
        \(brewExe) services restart httpd
        """
        
        Task {
            await runAsync(command, onOutput: { _ in })
            DispatchQueue.main.async { self.isBusy = false }
        }
    }

    // MARK: - INSTALACJA / DEINSTALACJA
    func installFullStack() {
        isBusy = true
        showCloseButton = false
        installLog = "Inicjalizacja instalatora GAMP...\n"
        
        Task {
            let appendLog: (String) -> Void = { self.installLog += $0 }
            
            DispatchQueue.main.async { self.busyMessage = "Instalowanie Apache, MySQL i PHP..." }
            await runAsync("\(brewExe) install httpd mysql php", onOutput: appendLog)
            
            DispatchQueue.main.async { self.busyMessage = "Konfigurowanie bazy danych..." }
            let mysqlSetup = """
            \(brewExe) services start mysql
            sleep 5
            \(brewPrefix)/bin/mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY ''; FLUSH PRIVILEGES;" || echo "Hasło już puste."
            """
            await runAsync(mysqlSetup, onOutput: appendLog)
            
            DispatchQueue.main.async { self.busyMessage = "Pobieranie phpMyAdmin..." }
            let pmaSetup = """
            mkdir -p \(htdocsPath) && cd \(htdocsPath)
            curl -O https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
            unzip -q phpMyAdmin-5.2.1-all-languages.zip
            rm -rf phpmyadmin && mv phpMyAdmin-5.2.1-all-languages phpmyadmin
            rm phpMyAdmin-5.2.1-all-languages.zip
            cat > phpmyadmin/config.inc.php <<EOF
            <?php
            \\$cfg['blowfish_secret'] = 'gamp_32_chars_secret_code_xyz_123';
            \\$i = 0; \\$i++;
            \\$cfg['Servers'][\\$i]['auth_type'] = 'config';
            \\$cfg['Servers'][\\$i]['user'] = 'root';
            \\$cfg['Servers'][\\$i]['password'] = '';
            \\$cfg['Servers'][\\$i]['AllowNoPassword'] = true;
            ?>
            EOF
            """
            await runAsync(pmaSetup, onOutput: appendLog)
            
            DispatchQueue.main.async { self.configureApacheForPHP() }
            
            DispatchQueue.main.async {
                self.checkStatus()
                self.isBusy = false
            }
        }
    }

    func uninstallFullStack() {
        isBusy = true
        installLog = "Usuwanie wszystkiego z systemu...\n"
        Task {
            let appendLog: (String) -> Void = { self.installLog += $0 }
            await runAsync("\(brewExe) services stop httpd mysql php", onOutput: appendLog)
            await runAsync("\(brewExe) uninstall --force httpd mysql php", onOutput: appendLog)
            
            let cleanup = "rm -rf \(brewPrefix)/etc/httpd \(brewPrefix)/etc/php \(brewPrefix)/var/mysql \(htdocsPath)/phpmyadmin"
            await runAsync(cleanup, onOutput: appendLog)
            
            DispatchQueue.main.async {
                self.magicDomains = []
                self.checkStatus()
                self.isBusy = false
            }
        }
    }

    // MARK: - NAPRAWA KONFIGURACJI
    func configureApacheForPHP() {
        isBusy = true
        busyMessage = "Optymalizacja PHP i Apache..."
        let phpLib = "\(brewPrefix)/opt/php/lib/httpd/modules/libphp.so"
        
        let command = """
            PHP_INI_PATH=$(php -r "echo php_ini_loaded_file();")
            if [ -f "$PHP_INI_PATH" ]; then
                sed -i '' 's/^display_errors = .*/display_errors = Off/g' "$PHP_INI_PATH"
                sed -i '' 's/^error_reporting = .*/error_reporting = E_ALL \\& ~E_DEPRECATED \\& ~E_STRICT/g' "$PHP_INI_PATH"
                sed -i '' 's/^memory_limit = .*/memory_limit = 512M/g' "$PHP_INI_PATH"
            fi

            sed -i '' 's/^LoadModule mpm_event_module/#LoadModule mpm_event_module/g' "\(httpdConfPath)"
            sed -i '' 's/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g' "\(httpdConfPath)"
            sed -i '' 's/^#LoadModule rewrite_module/LoadModule rewrite_module/g' "\(httpdConfPath)"
            
            sed -i '' '/# --- GAMP PHP CONFIG ---/d' "\(httpdConfPath)"
            sed -i '' '/LoadModule php_module/d' "\(httpdConfPath)"
            
            echo "\n# --- GAMP PHP CONFIG ---\nLoadModule php_module \(phpLib)\n<FilesMatch \\"\\\\.php$\\">\n    SetHandler application/x-httpd-php\n</FilesMatch>" >> "\(httpdConfPath)"
            sed -i '' 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' "\(httpdConfPath)"
            
            \(brewExe) services restart httpd
            """
        Task {
            await runAsync(command, onOutput: { _ in })
            DispatchQueue.main.async { self.checkStatus(); self.isBusy = false }
        }
    }

    // MARK: - POMOCNICZE
    private func runAsync(_ command: String, onOutput: @escaping (String) -> Void) async {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "export PATH=\"\(brewPrefix)/bin:/usr/local/bin:$PATH\"; \(command)"]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async { onOutput(str) }
            }
        }
        
        do { try task.run(); task.waitUntilExit() } catch { }
        fileHandle.readabilityHandler = nil
    }
    
    func toggleApache() {
        isBusy = true
        let action = isApacheRunning ? "stop" : "start"
        Task {
            await runAsync("\(brewExe) services \(action) httpd", onOutput: { _ in })
            DispatchQueue.main.async { self.checkStatus(); self.isBusy = false }
        }
    }
    
    func toggleMySQL() {
        isBusy = true
        let action = isMySQLRunning ? "stop" : "start"
        Task {
            await runAsync("\(brewExe) services \(action) mysql", onOutput: { _ in })
            DispatchQueue.main.async { self.checkStatus(); self.isBusy = false }
        }
    }

    func installHomebrew() {
        TerminalHelper.runInTerminal("/bin/bash -c \\\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\\\"")
    }

    private func saveDomains() {
        if let encoded = try? JSONEncoder().encode(magicDomains) {
            UserDefaults.standard.set(encoded, forKey: "MagicDomains")
        }
    }
    
    private func loadDomains() {
        if let data = UserDefaults.standard.data(forKey: "MagicDomains"),
           let decoded = try? JSONDecoder().decode([MagicDomain].self, from: data) {
            magicDomains = decoded
        }
    }
}
