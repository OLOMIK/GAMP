//
//  MissingHomebrewView.swift
//  GAMP
//
//  Created by Aleksander Marciniak on 3/23/26.
//


import SwiftUI

struct MissingHomebrewView: View {
    @Environment(ServicesViewModel.self) var viewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("Wymagany Homebrew")
                .font(.largeTitle.bold())
            
            Text("Ta aplikacja używa Homebrew do zarządzania serwerami Apache i MySQL. System go nie wykrył.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 50)
            
            Button("Zainstaluj Homebrew automatycznie") {
                viewModel.installHomebrew()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
            
            Text("Otworzy się okno Terminala – może być wymagane podanie hasła administratora Maca.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}