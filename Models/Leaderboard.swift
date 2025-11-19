//
//  Leaderboard.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 11/18/25.
//

import Foundation
import Observation

struct LeaderboardEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var playerName: String
    var score: Int
    var achievedAt: Date

    init(id: UUID = UUID(), playerName: String, score: Int, achievedAt: Date = Date()) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.achievedAt = achievedAt
    }
}

@Observable
final class LeaderboardStore {
    static let shared = LeaderboardStore()
    private let defaults = UserDefaults.standard
    private let storageKey = "hilo.leaderboard.entries"

    private(set) var entries: [LeaderboardEntry] = []

    private init() {
        load()
    }

    func recordScore(_ score: Int, playerName: String) {
        let entry = LeaderboardEntry(playerName: playerName, score: score)
        entries.append(entry)
        entries.sort { $0.score > $1.score }
        if entries.count > 3 { entries = Array(entries.prefix(3)) }
        save()
    }

    func reset() {
        entries.removeAll()
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else { return }
        entries = decoded.sorted { $0.score > $1.score }
        if entries.count > 3 { entries = Array(entries.prefix(3)) }
    }
}
