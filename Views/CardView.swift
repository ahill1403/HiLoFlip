//
//  CardView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 9/15/25.
//

import SwiftUI

struct CardView: View {
    var card: HiLoGame.Card
    var forceFaceUp: Bool? = nil

    @State private var idleWiggle = false

    private var isUp: Bool { forceFaceUp ?? card.isFaceUp }

    private let cornerNumberSize: CGFloat = 20
    private let cornerSymbolScale: CGFloat = 0.7
    private let cornerStackSpacing: CGFloat = 2
    private let cornerPadding: CGFloat = 4

    private let badgeSize: CGFloat = 50
    private let badgeInset: CGFloat = 10
    private let badgeLine: CGFloat = 2

    var body: some View {
        ZStack { cardFace }
            .frame(width: 80, height: 126)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(radius: 2)

            .rotation3DEffect(.degrees(isUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .animation(.bouncy(duration: 0.45), value: isUp)

            .onAppear {
                withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                    idleWiggle.toggle()
                }
            }
            .rotationEffect(.degrees(idleWiggle ? 0.6 : -0.6))
    }

    // MARK: - Face

    @ViewBuilder
    private var cardFace: some View {
        let showUp = forceFaceUp ?? card.isFaceUp
        if showUp { faceUp } else { faceDown }
    }

    private var faceUp: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorForIndex(card.value))

            centerNumberChip

            let needsRing = (card.value % 10 == 1)

            VStack(alignment: .leading, spacing: cornerStackSpacing) {
                smallNumberChip
                if let shape = cornerShape {
                    CornerBadge(shape: shape,
                                symbolScale: cornerSymbolScale,
                                hasRing: needsRing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(cornerPadding)
            .offset(x: -1, y: 1)

            VStack(alignment: .trailing, spacing: cornerStackSpacing) {
                smallNumberChip
                if let shape = cornerShape {
                    CornerBadge(shape: shape,
                                symbolScale: cornerSymbolScale,
                                hasRing: needsRing)
                }
            }
            .rotationEffect(.degrees(180))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(cornerPadding)
            .offset(x: 1, y: 1)
        }
        .padding(2)
    }

    private var centerNumberChip: some View {
        ZStack {
            Circle().fill(Color.black).frame(width: 54, height: 54)
            Text("\(card.value)")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.4)
        }
        .accessibilityHidden(true)
    }

    private var smallNumberChip: some View {
        ZStack {
            Circle().fill(Color.black)
            Text("\(card.value)")
                .font(.system(size: cornerNumberSize * 0.55,
                              weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
        }
        .frame(width: cornerNumberSize, height: cornerNumberSize)
        .accessibilityHidden(true)
    }

    private var cornerShape: AnyShape? {
        switch card.value % 10 {
        case 0: return AnyShape(TenPointSymbol())
        case 1: return AnyShape(SkipSymbol())
        case 2: return AnyShape(MustPlaySecondSymbol())
        default: return nil
        }
    }

    // MARK: - Face Down

    private var faceDown: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black)

            faceDownBadge("HI", size: badgeSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(badgeInset)

            faceDownBadge("LO", size: badgeSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(badgeInset)
        }
    }

    private func faceDownBadge(_ text: String, size: CGFloat) -> some View {
        ZStack {
            Circle().stroke(.white, lineWidth: badgeLine)
            Text(text)
                .font(.system(size: size * 0.45, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct CornerBadge: View {
    let shape: AnyShape
    var symbolScale: CGFloat
    var hasRing: Bool

    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            if hasRing {
                Circle().inset(by: 4).stroke(Color.black, lineWidth: 2.5)
            }
            shape
                .fill(Color.black)
                .scaleEffect(symbolScale)
        }
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
}

#Preview("51") { CardView(card: HiLoGame.Card(value: 51)) }
#Preview("10") { CardView(card: HiLoGame.Card(value: 10)) }
#Preview("42") { CardView(card: HiLoGame.Card(value: 42)) }
#Preview("Down") { CardView(card: HiLoGame.Card(value: 40), forceFaceUp: false) }
