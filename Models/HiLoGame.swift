//
//  HiLoGame.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 9/30/25.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct HiLoGame: Codable {
    struct Card: Identifiable, Hashable, Codable {
        let id: UUID
        let value: Int
        fileprivate(set) var isFaceUp: Bool
        private(set) var isSpecialCard: Bool
        private(set) var isTenPointCard: Bool
        private(set) var isSkipCard: Bool
        private(set) var isMustPlaySecondCard: Bool

        init(value: Int, id: UUID = UUID(), isFaceUp: Bool = true) {
            self.id = id
            self.value = value
            self.isFaceUp = isFaceUp
            let last = value % 10
            self.isTenPointCard = (last == 0)
            self.isSkipCard = (last == 1)
            self.isMustPlaySecondCard = (last == 2)
            self.isSpecialCard = isTenPointCard || isSkipCard || isMustPlaySecondCard
        }
    }

    struct Player: Identifiable, Hashable, Codable {
        let id: UUID
        fileprivate(set) var name: String
        fileprivate(set) var hand: [Card]
        fileprivate(set) var score: Int

        init(name: String, id: UUID = UUID()) {
            self.id = id
            self.name = name
            self.hand = []
            self.score = 0
        }
    }

    private(set) var deck: [Card]
    private(set) var players: [Player]
    private(set) var isTokenHi: Bool
    private(set) var discardPile: [Card]

    init(playerNames: [String]) {
        self.isTokenHi = Bool.random()
        self.deck = (1...100).map { Card(value: $0) }
        self.players = playerNames.map { Player(name: $0) }
        self.discardPile = []
    }

    private mutating func clearHands() {
        for i in players.indices { players[i].hand.removeAll() }
    }

    mutating func dealCards(cardsPerPlayer: Int = 7) {
        deck.shuffle()
        clearHands()
        discardPile.removeAll()
        guard !players.isEmpty else { return }

        for _ in 0..<cardsPerPlayer {
            for i in players.indices {
                guard !deck.isEmpty else { return }
                players[i].hand.append(deck.removeFirst())
            }
        }
        if let starter = drawFromDeck() {
            discardPile.append(starter)
        }
    }

    mutating func resetGame() {
        isTokenHi = Bool.random()
        deck = (1...100).map { Card(value: $0) }
        dealCards()
    }

    mutating func drawFromDeck() -> Card? {
        guard !deck.isEmpty else { return nil }
        return deck.removeFirst()
    }

    mutating func removeCardFromPlayerHand(playerID: UUID, cardID: UUID) -> Card? {
        guard let pIndex = players.firstIndex(where: { $0.id == playerID }) else { return nil }
        guard let cIndex = players[pIndex].hand.firstIndex(where: { $0.id == cardID }) else { return nil }
        return players[pIndex].hand.remove(at: cIndex)
    }

    mutating func pushToDiscard(_ card: Card) { discardPile.append(card) }

    func topOfDiscard() -> Card? { discardPile.last }

    mutating func setPlayerName(index: Int, name: String) {
        guard players.indices.contains(index) else { return }
        players[index].name = name
    }

    mutating func setCardFaceUp(playerID: UUID, isFaceUp: Bool) {
        guard let pIndex = players.firstIndex(where: { $0.id == playerID }) else { return }
        for i in players[pIndex].hand.indices {
            players[pIndex].hand[i].isFaceUp = isFaceUp
        }
    }

    mutating func awardPoints(to playerID: UUID, points: Int) {
        guard let pIndex = players.firstIndex(where: { $0.id == playerID }) else { return }
        players[pIndex].score += points
    }
}

extension HiLoGame.Card: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

