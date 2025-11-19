//
//  InstructionsView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 11/4/25.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("How to Play HiLo").font(.title).bold()
                Text("• At the start of each play, the center token randomly shows HIGHER (HI) or LOWER (LO).")
                Text("• Drag a card from your hand to the discard pile that matches the token direction against the top discard card.")
                Text("• If you cannot play, tap the deck to draw a card. If the drawn card fits the HI/LO rule, it plays immediately; otherwise it stays in your hand and your turn ends (tapping an empty deck simply passes and flips HI/LO).")
                Text("• Special cards:")
                Text(" – 0: Ten-point card (no scoring required in this assignment).")
                Text(" – 1: Skip card – the next player's turn is skipped.")
                Text(" – 2: Must-play-second – you must immediately play another card before turns switch (with a fresh HI/LO flip).")
                Text("• Hands: the current player's hand is face-up; the other player's is face-down.")
                Text("• This assignment only requires one round (one player may play all their cards).")
            }
            .padding()
        }
        .navigationTitle("Instructions")
    }
}
