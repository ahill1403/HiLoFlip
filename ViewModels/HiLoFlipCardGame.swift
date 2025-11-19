//
//  HiLoFlipCardGame.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 9/30/25.
//

import Observation
import Foundation

@Observable
final class HiLoFlipCardGame {
    // MARK: - Persistence
    private enum Constants {
        static let gameStateKey = "hilo.game.state"
        static let soundEnabledKey = "hilo.sound.enabled"
    }
    
    struct PersistedState: Codable {
        var game: HiLoGame
        var currentPlayerIndex: Int
        var mustPlaySecondPending: Bool
    }
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Core model
    private var game: HiLoGame
    
    var players: [HiLoGame.Player] { game.players }
    var isTokenHi: Bool { game.isTokenHi }
    var discardTop: HiLoGame.Card? { game.topOfDiscard() }
    var deckCount: Int { game.deck.count }
    
    var currentPlayerIndex: Int = 0
    var mustPlaySecondPending: Bool = false
    
    var lastDropInvalidTick: Int = 0
    var soundsEnabled: Bool { didSet { defaults.set(soundsEnabled, forKey: Constants.soundEnabledKey) } }
    
    private let defaultNames: [String]
    
    var playerNames: [String] {
        get { game.players.map { $0.name } }
        set {
            for (i, name) in newValue.enumerated() { game.setPlayerName(index: i, name: name) }
            persistState()
        }
    }
    
    init(playerNames: [String], defaultNames: [String] = ["Crimson Fox", "Golden Gale"]) {
        self.defaultNames = defaultNames
        self.soundsEnabled = defaults.object(forKey: Constants.soundEnabledKey) as? Bool ?? true
        self.game = HiLoGame(playerNames: playerNames)
        self.game.dealCards()
        randomizeToken()
        revealCurrentPlayerHand()
        persistState()
    }
    
    init(savedState: PersistedState, defaultNames: [String]) {
        self.defaultNames = defaultNames
        self.soundsEnabled = defaults.object(forKey: Constants.soundEnabledKey) as? Bool ?? true
        self.game = savedState.game
        self.currentPlayerIndex = min(savedState.currentPlayerIndex, max(0, game.players.count - 1))
        self.mustPlaySecondPending = savedState.mustPlaySecondPending
        revealCurrentPlayerHand()
    }
    
    static func loadSavedOrNew(defaultNames: [String] = ["Crimson Fox", "Golden Gale"]) -> HiLoFlipCardGame {
        if let state = loadState() {
            return HiLoFlipCardGame(savedState: state, defaultNames: defaultNames)
        }
        return HiLoFlipCardGame(playerNames: defaultNames, defaultNames: defaultNames)
    }
    
    var currentPlayer: HiLoGame.Player { players[currentPlayerIndex] }
    var nonCurrentPlayer: HiLoGame.Player { players[(currentPlayerIndex + 1) % players.count] }
    
    // MARK: - Public API
    
    func resetGame() {
        mustPlaySecondPending = false
        currentPlayerIndex = 0
        game.resetGame()
        randomizeToken()
        revealCurrentPlayerHand()
        persistState()
    }
    
    func resetGameState() {
        clearSavedState()
        newGame(with: defaultNames)
    }
    
    func newGame(with names: [String]) {
        self.game = HiLoGame(playerNames: names)
        mustPlaySecondPending = false
        currentPlayerIndex = 0
        game.dealCards()
        randomizeToken()
        revealCurrentPlayerHand()
        persistState()
    }
    
    func hand(for player: HiLoGame.Player) -> [HiLoGame.Card] {
        guard let idx = game.players.firstIndex(where: { $0.id == player.id }) else { return [] }
        return game.players[idx].hand
    }
    
    func canDrag(_ card: HiLoGame.Card, owner: HiLoGame.Player) -> Bool {
        owner.id == currentPlayer.id
    }
    
    func canPlay(_ card: HiLoGame.Card) -> Bool {
        guard let top = game.topOfDiscard() else { return true }
        if game.isTokenHi {
            return card.value > top.value
        } else {
            return card.value < top.value
        }
    }
    
    @discardableResult
    func tryPlayFromDrop(_ card: HiLoGame.Card, owner: HiLoGame.Player) -> Bool {
        guard owner.id == currentPlayer.id else {
            lastDropInvalidTick += 1
            Task { await SoundManager.shared.play(.invalidMove) }
            return false
        }
        guard canPlay(card) else {
            lastDropInvalidTick += 1
            Task { await SoundManager.shared.play(.invalidMove) }
            return false
        }
        return true
    }
    
    func play(card: HiLoGame.Card, from player: HiLoGame.Player) {
        guard player.id == currentPlayer.id else { return }
        guard canPlay(card) else {
            lastDropInvalidTick += 1
            Task { await SoundManager.shared.play(.invalidMove) }
            return
        }

        guard let removed = game.removeCardFromPlayerHand(playerID: player.id, cardID: card.id) else { return }
        game.pushToDiscard(removed)
        randomizeToken()

        Task {
            if soundsEnabled {
                await SoundManager.shared.play(soundType(for: removed))
            }
        }
        
        var didSkip = false
        if removed.isSkipCard { didSkip = true }

        if removed.isMustPlaySecondCard {
            if mustPlaySecondPending {
                mustPlaySecondPending = false
            } else {
                mustPlaySecondPending = true
                persistState()
                return
            }
        }

        if game.players[currentPlayerIndex].hand.isEmpty {
            completeRound(winner: currentPlayer)
        } else {
            advanceTurn(skippingNext: didSkip)
        }
    }

    @discardableResult
    func drawCardForCurrentPlayer() -> HiLoGame.Card? {
        guard let drawn = game.drawCard(for: currentPlayer.id) else {
            if deckCount == 0 && !mustPlaySecondPending {
                randomizeToken()
                advanceTurn(skippingNext: false)
            } else {
                lastDropInvalidTick += 1
                Task { await SoundManager.shared.play(.invalidMove) }
            }
            return nil
        }
        revealCurrentPlayerHand()
        persistState()

        if canPlay(drawn) {
            play(card: drawn, from: currentPlayer)
        } else if !mustPlaySecondPending {
            randomizeToken()
            advanceTurn(skippingNext: false)
        }
        return drawn
    }

    // MARK: - Turn
    
    private func advanceTurn(skippingNext: Bool) {
        guard !mustPlaySecondPending else { return }
        let step = skippingNext ? 2 : 1
        currentPlayerIndex = (currentPlayerIndex + step) % players.count
        revealCurrentPlayerHand()
        persistState()
    }
    
    private func revealCurrentPlayerHand() {
        for (i, p) in players.enumerated() {
            game.setCardFaceUp(playerID: p.id, isFaceUp: (i == currentPlayerIndex))
        }
    }
    
    private func completeRound(winner: HiLoGame.Player) {
        let pointsFromPile = game.discardPile.reduce(0) { partialResult, card in
            partialResult + (card.isTenPointCard ? 10 : 1)
        }
        let totalPoints = pointsFromPile + 10
        game.awardPoints(to: winner.id, points: totalPoints)
        LeaderboardStore.shared.recordScore(game.players.first(where: { $0.id == winner.id })?.score ?? totalPoints, playerName: winner.name)
        
        mustPlaySecondPending = false
        currentPlayerIndex = players.firstIndex(where: { $0.id == winner.id }) ?? 0
        game.resetGame()
        revealCurrentPlayerHand()
        persistState()
    }
    
    private func persistState() {
        let state = PersistedState(game: game, currentPlayerIndex: currentPlayerIndex, mustPlaySecondPending: mustPlaySecondPending)
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: Constants.gameStateKey)
    }
    
    private func clearSavedState() {
        defaults.removeObject(forKey: Constants.gameStateKey)
    }
    
    private static func loadState() -> PersistedState? {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: Constants.gameStateKey) else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }

    private func randomizeToken() {
        game.setToken(isHi: Bool.random())
    }
    
    private func soundType(for card: HiLoGame.Card) -> SoundEffect {
        if card.isTenPointCard { return .specialStar }      // 0-card sound
        if card.isSkipCard { return .specialSkip }          // 1-card sound
        if card.isMustPlaySecondCard { return .specialReset } // 2-card sound
        return .cardDrop                                    // normal card
    }
}
