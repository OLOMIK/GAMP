<div align="center">


<img src="https://github.com/OLOMIK/GAMP/blob/main/GAMP/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" width="128" height="128" />

# 🚀 GAMP 

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=flat-square)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat-square)
![Swift](https://img.shields.io/badge/language-Swift-orange.svg?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)
![Contributors](https://img.shields.io/github/contributors/OLOMIK/GAMP?style=flat-square)
![Pull Requests](https://img.shields.io/github/issues-pr/OLOMIK/GAMP?style=flat-square)
![Issues](https://img.shields.io/github/issues/OLOMIK/GAMP?style=flat-square)
![Stars](https://img.shields.io/github/stars/OLOMIK/GAMP?style=flat-square)
</div>


### The Modern XAMPP Alternative for macOS (2026 Edition)

GAMP to lekka, natywna i piekielnie szybka konsola do zarządzania lokalnym środowiskiem deweloperskim (Apache, MySQL, PHP) na systemach macOS. Zapomnij o ciężkich, przestarzałych instalatorach. GAMP wykorzystuje potęgę Homebrew, aby dostarczyć Ci środowisko "production-ready" w kilka minut.

## ✨ Dlaczego GAMP?

- **Magic Domains (VHosts):** Twórz domeny typu `moj-projekt.test` jednym kliknięciem. GAMP automatycznie konfiguruje Apache i Twój systemowy plik hosts.
- **Engine Core (PHP Switcher):** Przełączaj się między wersjami PHP (8.2, 8.3, 8.4) w locie, bez dotykania terminala.
- **XAMPP Experience:** Domyślnie skonfigurowany użytkownik `root` bez hasła oraz autologowanie do phpMyAdmin.
- **Clean UI:** Natywny interfejs SwiftUI zaprojektowany pod macOS Monterey+, z obsługą Liquid Glass.
- **Safety First:** Wbudowany "Nuklearny Przycisk" do całkowitej deinstalacji i czyszczenia systemu ze wszystkich śmieci.

## 🛠️ Instalacja

1. Pobierz plik `GAMP_Setup.dmg`.
2. Przeciągnij GAMP do folderu `Applications`.
3. Przy pierwszym uruchomieniu aplikacja sprawdzi obecność Homebrew i zaproponuje automatyczną instalację całego stacku (Apache/MySQL/PHP).

> **Ważne (Unidentified Developer):** Jeśli macOS zablokuje uruchomienie, kliknij ikonę prawym przyciskiem myszy i wybierz "Otwórz".

## 📂 Struktura folderów

- **Htdocs:** `/opt/homebrew/var/www` (lub `/usr/local/var/www` na Intelu)
- **Config:** `/opt/homebrew/etc/httpd/httpd.conf`
- **phpMyAdmin:** Dostępny pod adresem `http://localhost:8080/phpmyadmin` lub `pma.test:8080`.

## 🤝 Autor
Stworzone przez **Aleksander Marciniak** [klik](https://github.com/OLOMIK/)<br>
Built for Developers, by Developer.
