import SwiftUI
import Observation

struct LeaderboardView: View {
    @Bindable var store: LeaderboardStore

    var body: some View {
        List {
            if store.entries.isEmpty {
                ContentUnavailableView("No scores yet", systemImage: "trophy")
            } else {
                ForEach(Array(store.entries.enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("#\(index + 1)")
                            .font(.headline)
                            .frame(width: 36)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.playerName)
                                .font(.headline)
                            Text(entry.achievedAt.formatted(date: .numeric, time: .shortened))
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                        Spacer()
                        Text("\(entry.score)")
                            .font(.title3.bold())
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .animation(.easeInOut, value: store.entries)
        .navigationTitle("Leaderboard")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset", role: .destructive) { store.reset() }
                    .disabled(store.entries.isEmpty)
            }
        }
    }
}

#Preview {
    LeaderboardView(store: LeaderboardStore.shared)
}
