//
//  HomeView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 11/4/25.
//

import SwiftUI

struct HomeView: View {
    @State private var gameVM = HiLoFlipCardGame.loadSavedOrNew()
    @State private var startNewGame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("HiLoFlip").font(.largeTitle).bold()
                Text("A quick game of higher or lower").foregroundStyle(.secondary)

                Button("New Game") {
                    gameVM.resetGame()
                    startNewGame = true
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Settings") {
                    SettingsView(vm: gameVM)
                }

                NavigationLink("Leaderboard") {
                    LeaderboardView(store: LeaderboardStore.shared)
                }

                NavigationLink("Instructions") {
                    InstructionsView()
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $startNewGame) {
                GameView(vm: gameVM)
            }
        }
    }
}
