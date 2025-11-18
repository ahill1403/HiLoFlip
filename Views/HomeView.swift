//
//  HomeView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 11/4/25.
//

import SwiftUI

struct HomeView: View {
    @State private var settingsVM = HiLoFlipCardGame(playerNames: ["Player 1", "Player 2"])
    @State private var startNewGame = false
    @State private var gameVM: HiLoFlipCardGame? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("HiLoFlip").font(.largeTitle).bold()
                Text("A quick game of higher or lower").foregroundStyle(.secondary)

                Button("New Game") {
                    gameVM = HiLoFlipCardGame(playerNames: settingsVM.playerNames)
                    startNewGame = true
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Settings") {
                    SettingsView(vm: settingsVM)
                }

                NavigationLink("Instructions") {
                    InstructionsView()
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $startNewGame) {
                if let vm = gameVM {
                    GameView(vm: vm)
                }
            }
        }
    }
}
