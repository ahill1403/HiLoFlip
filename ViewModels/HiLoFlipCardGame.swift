//
//  HiLoFlipCardGame.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 9/30/25.
//

import Observation

@Observable
final class HiLoFlipCardGame {
    // MARK: - Core model
    private var game: HiLoGame

    var players: [HiLoGame.Player] { game.players }
    var isTokenHi: Bool { game.isTokenHi }
    var discardTop: HiLoGame.Card? { game.topOfDiscard() }
    var deckCount: Int { max(0, internalDeckCount) }

    var currentPlayerIndex: Int = 0
    var mustPlaySecondPending: Bool = false

    var lastDropInvalidTick: Int = 0

    var playerNames: [String] {
        get { game.players.map { $0.name } }
        set {
            for (i, name) in newValue.enumerated() { game.setPlayerName(index: i, name: name) }
        }
    }

    init(playerNames: [String]) {
        self.game = HiLoGame(playerNames: playerNames)
        self.game.dealCards()
        revealCurrentPlayerHand()
    }

    var currentPlayer: HiLoGame.Player { players[currentPlayerIndex] }
    var nonCurrentPlayer: HiLoGame.Player { players[(currentPlayerIndex + 1) % players.count] }

    private var internalDeckCount: Int {
        let totalDealt = players.reduce(0) { $0 + $1.hand.count } + (game.discardPile.count)
        return max(0, 100 - totalDealt)
    }

    // MARK: - Public API

    func resetGame() {
        mustPlaySecondPending = false
        currentPlayerIndex = 0
        game.resetGame()
        revealCurrentPlayerHand()
    }

    func newGame(with names: [String]) {
        self.game = HiLoGame(playerNames: names)
        mustPlaySecondPending = false
        currentPlayerIndex = 0
        game.dealCards()
        revealCurrentPlayerHand()
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
        guard owner.id == currentPlayer.id else { lastDropInvalidTick += 1; return false }
        guard canPlay(card) else { lastDropInvalidTick += 1; return false }
        play(card: card, from: owner)
        return true
    }

    func play(card: HiLoGame.Card, from player: HiLoGame.Player) {
        guard player.id == currentPlayer.id else { return }
        guard canPlay(card) else { lastDropInvalidTick += 1; return }
        guard let removed = game.removeCardFromPlayerHand(playerID: player.id, cardID: card.id) else { return }
        game.pushToDiscard(removed)

        var didSkip = false
        if removed.isSkipCard { didSkip = true }

        if removed.isMustPlaySecondCard {
            if mustPlaySecondPending {
                mustPlaySecondPending = false
            } else {
                mustPlaySecondPending = true
                return
            }
        }

        advanceTurn(skippingNext: didSkip)
    }

    // MARK: - Turn

    private func advanceTurn(skippingNext: Bool) {
        guard !mustPlaySecondPending else { return }
        let step = skippingNext ? 2 : 1
        currentPlayerIndex = (currentPlayerIndex + step) % players.count
        revealCurrentPlayerHand()
    }

    private func revealCurrentPlayerHand() {
        for (i, p) in players.enumerated() {
            game.setCardFaceUp(playerID: p.id, isFaceUp: (i == currentPlayerIndex))
        }
    }
}
