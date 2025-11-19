//
//  GameView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 9/15/25.
//

import SwiftUI

private let tableGreen = Color(red: 0/255, green: 119/255, blue: 0/255)

func colorForIndex(_ index: Int) -> Color {
    let hue = Double((index - 1) % 100) / 100.0
    return Color(hue: hue, saturation: 0.8, brightness: 1)
}

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showQuitConfirm = false

    @State var vm: HiLoFlipCardGame

    @Namespace private var cardNS
    @State private var isHoveringDiscard = false
    @State private var discardPop = false
    @State private var tokenSpinTick = 0
    @State private var showSpotlight = false

    private let columns = [GridItem(.adaptive(minimum: 86, maximum: 120), spacing: 10)]

    var body: some View {
        ZStack {
            tableGreen.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    if let top = vm.players.first {
                        grid(for: top, isTop: true)
                    }

                    centerArea

                    if vm.players.count > 1 {
                        grid(for: vm.players[1], isTop: false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .safeAreaPadding(.horizontal, 12)
                .safeAreaPadding(.vertical, 14)
            }

            if showSpotlight {
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Quit") { showQuitConfirm = true }
            }
        }
        .confirmationDialog("Quit the game?", isPresented: $showQuitConfirm, titleVisibility: .visible) {
            Button("Quit", role: .destructive) { dismiss() }
            Button("Cancel", role: .cancel) { }
        }
        .navigationBarBackButtonHidden(true)

        .onChange(of: vm.currentPlayerIndex) { _ in
            showSpotlight = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showSpotlight = false }
            tokenSpinTick += 1
        }
        .onChange(of: vm.isTokenHi) { _ in
            tokenSpinTick += 1
        }
    }

    private var centerArea: some View {
        HStack(spacing: 18) {

            PhaseAnimator(
                [0, 1, 0],
                trigger: tokenSpinTick,
                content: { phase in
                    TokenView(isHi: vm.isTokenHi)
                        .rotation3DEffect(.degrees(phase == 1 ? 180 : 0), axis: (0,1,0))
                },
                animation: { _ in .spring(response: 0.5, dampingFraction: 0.7) }
            )

            DeckView(count: vm.deckCount)

            DiscardPileView(top: vm.discardTop, pop: discardPop, namespace: cardNS)
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isHoveringDiscard ? .yellow : .clear, lineWidth: 4)
                        .glow(color: .yellow, radius: isHoveringDiscard ? 12 : 0)
                        .animation(.easeInOut(duration: 0.18), value: isHoveringDiscard)
                )
                .dropDestination(for: HiLoGame.Card.self) { items, _ in
                    guard let card = items.first else { return false }
                    let before = vm.discardTop?.id
                    let ok = vm.tryPlayFromDrop(card, owner: vm.currentPlayer)
                    if ok {
                        vm.play(card: card, from: vm.currentPlayer)
                        if before != vm.discardTop?.id { discardPop.toggle() }
                    }
                    return ok
                } isTargeted: { hovering in
                    isHoveringDiscard = hovering
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private func grid(for player: HiLoGame.Player, isTop: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(playerNameLine(player, isTop: isTop))
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Score")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(player.score)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }

            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(Array(vm.hand(for: player).enumerated()), id: \.element.id) { idx, card in
                    CardView(card: card)
                        .modifier(DealIn(index: idx))
                        .scaleEffect(vm.canDrag(card, owner: player) ? 1.03 : 1.0)
                        .shadow(radius: vm.canDrag(card, owner: player) ? 10 : 0)
                        .matchedGeometryEffect(id: card.id, in: cardNS)
                        .draggable(card)
                        .allowsHitTesting(vm.canDrag(card, owner: player))
                        .animation(.easeInOut(duration: 0.15), value: vm.currentPlayerIndex)
                }
            }
        }
        .modifier(Shake(animatableData: CGFloat(player.id == vm.currentPlayer.id ? vm.lastDropInvalidTick : 0)))
        .animation(.easeOut(duration: 0.28), value: vm.lastDropInvalidTick)
    }

    private func playerNameLine(_ player: HiLoGame.Player, isTop: Bool) -> String {
        let arrow = (player.id == vm.currentPlayer.id) ? "⏺" : " "
        return isTop ? "⟦ \(player.name) ⟧  •  \(arrow)" : "\(arrow)  •  ⟦ \(player.name) ⟧"
    }
}

// MARK: - Glow

fileprivate struct Glow: ViewModifier {
    let color: Color; let radius: CGFloat
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(radius > 0 ? 0.7 : 0), radius: radius)
            .shadow(color: color.opacity(radius > 0 ? 0.35 : 0), radius: radius * 0.5)
    }
}
fileprivate extension View {
    func glow(color: Color, radius: CGFloat) -> some View { modifier(Glow(color: color, radius: radius)) }
}

// MARK: - Shake

fileprivate struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0)
        )
    }
}

// MARK: - Deal-in fan

fileprivate struct DealIn: ViewModifier {
    let index: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : -24)
            .rotationEffect(.degrees(appeared ? 0 : Double.random(in: -6...6)))
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78).delay(0.05 * Double(index))) {
                    appeared = true
                }
            }
    }
}

// MARK: - Center Views

struct DiscardPileView: View {
    let top: HiLoGame.Card?
    var pop: Bool = false
    var namespace: Namespace.ID

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                .frame(width: 110, height: 150)
            if let top = top {
                CardView(card: top, forceFaceUp: true)
                    .matchedGeometryEffect(id: top.id, in: namespace)
                    .scaleEffect(pop ? 1.06 : 1.0)
                    .animation(.spring(response: 0.22, dampingFraction: 0.55), value: pop)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("Discard")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .accessibilityLabel("Discard pile")
    }
}

struct DeckView: View {
    let count: Int
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.black)
                .frame(width: 110, height: 150)
            Text("Deck\n\(count)")
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .accessibilityLabel("Deck with \(count) cards remaining")
    }
}

#Preview("GameView") {
    NavigationStack { GameView(vm: HiLoFlipCardGame(playerNames: ["P1", "P2"])) }
}
