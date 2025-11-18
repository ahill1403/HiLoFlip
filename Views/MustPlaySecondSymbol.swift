//
//  MustPlaySecondSymbol.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 10/21/25.
//

import SwiftUI

struct MustPlaySecondSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height
        let cardW = w * 0.48
        let cardH = h * 0.70
        let radius = min(cardW, cardH) * 0.12

        let backOffsetX = -w * 0.10
        let backOffsetY = -h * 0.10
        let backRect = CGRect(
            x: rect.midX - cardW/2 + backOffsetX,
            y: rect.midY - cardH/2 + backOffsetY,
            width: cardW, height: cardH
        )
        path.addPath(Path(roundedRect: backRect, cornerRadius: radius))

        let frontRect = CGRect(
            x: rect.midX - cardW/2 + w * 0.06,
            y: rect.midY - cardH/2 + h * 0.06,
            width: cardW, height: cardH
        )
        path.addPath(Path(roundedRect: frontRect, cornerRadius: radius))

        return path
    }
}
