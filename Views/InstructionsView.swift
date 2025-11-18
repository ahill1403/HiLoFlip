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
                Text("• The center token shows if you must play HIGHER (HI) or LOWER (LO) than the top discard card.")
                Text("• On your turn, drag a card from your hand to the discard pile. It must be either higher, or lower, than the top card in the discard pile.")
                Text("• Special cards:")
                Text(" – 0: Ten-point card (no scoring required in this assignment).")
                Text(" – 1: Skip card – the next player's turn is skipped.")
                Text(" – 2: Must-play-second – you must immediately play another card before turns switch.")
                Text("• Hands: the current player's hand is face-up; the other player's is face-down.")
                Text("• This assignment only requires one round (one player may play all their cards).")
            }
            .padding()
        }
        .navigationTitle("Instructions")
    }
}
