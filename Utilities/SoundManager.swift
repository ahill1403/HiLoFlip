//
//  SoundManager.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 11/18/25.
//

import Foundation
import AVFoundation

enum SoundEffect: String, CaseIterable {
    case cardDrop      = "card_drop"
    case specialStar   = "special_star"
    case specialSkip   = "special_skip"
    case specialReset  = "special_reset"
    case invalidMove   = "invalid_move"

    var fileExtension: String { "mp3" }   // change to "wav" if needed
}

@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private var players: [SoundEffect: AVAudioPlayer] = [:]

    // Shared toggle key with SettingsView
    private let soundEnabledKey = "soundEnabled"

    private init() {
        // Default: sounds ON
        UserDefaults.standard.register(defaults: [soundEnabledKey: true])
        preloadPlayers()
    }

    private func preloadPlayers() {
        for effect in SoundEffect.allCases {
            do {
                let player = try makePlayer(for: effect)
                players[effect] = player
            } catch {
                // Graceful error handling: log but don’t crash
                print("⚠️ Failed to preload sound \(effect): \(error)")
            }
        }
    }

    private func makePlayer(for effect: SoundEffect) throws -> AVAudioPlayer {
        guard let url = Bundle.main.url(forResource: effect.rawValue,
                                        withExtension: effect.fileExtension) else {
            throw SoundError.missingFile(name: "\(effect.rawValue).\(effect.fileExtension)")
        }

        let player = try AVAudioPlayer(contentsOf: url)
        player.prepareToPlay()
        return player
    }

    // Simple error type for logging
    enum SoundError: Error {
        case missingFile(name: String)
    }

    // Async API for playing a sound
    func play(_ effect: SoundEffect) async {
        // Respect Settings toggle
        guard UserDefaults.standard.bool(forKey: soundEnabledKey) else { return }

        do {
            let player: AVAudioPlayer

            if let cached = players[effect] {
                player = cached
            } else {
                let newPlayer = try makePlayer(for: effect)
                players[effect] = newPlayer
                player = newPlayer
            }

            // Restart sound from beginning, keep gameplay responsive
            player.currentTime = 0
            player.play()
        } catch {
            // Graceful error handling
            print("⚠️ Failed to play sound \(effect): \(error)")
        }
    }
}
