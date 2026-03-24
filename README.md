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

GAMP is a lightweight, native, and blazing-fast console for managing your local development environment (Apache, MySQL, PHP) on macOS. Forget heavy, outdated installers. GAMP harnesses the power of Homebrew to deliver a "production-ready" environment in minutes.

## ✨ Why GAMP?

- **Magic Domains (VHosts):** Create `your-project.test` domains with a single click. GAMP automatically configures Apache and your system hosts file.
- **Engine Core (PHP Switcher):** Switch between PHP versions (8.2, 8.3, 8.4) on the fly, without touching the terminal.
- **XAMPP Experience:** Default `root` user with no password and auto-login to phpMyAdmin.
- **Clean UI:** Native SwiftUI interface designed for macOS Monterey+, with Liquid Glass support.
- **Safety First:** Built-in "Nuclear Button" for total uninstallation and cleaning the system of all clutter.

## 🛠️ Installation

1. Download the `GAMP_Setup.dmg` file.
2. Drag GAMP to your `Applications` folder.
3. On the first run, the app will check for Homebrew and suggest an automatic installation of the entire stack (Apache/MySQL/PHP).

> **Important (Unidentified Developer):** If macOS blocks the launch, right-click the icon and select "Open".

## 📂 Folder Structure

- **Htdocs:** `/opt/homebrew/var/www` (or `/usr/local/var/www` on Intel)
- **Config:** `/opt/homebrew/etc/httpd/httpd.conf`
- **phpMyAdmin:** Available at `http://localhost:8080/phpmyadmin` or `pma.test:8080`.

## 🤝 Author
Created by **Aleksander Marciniak** [click](https://github.com/OLOMIK/)<br>
Built for Developers, by a Developer.
