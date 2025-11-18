//
//  SkipSymbol.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 10/21/25.
//

import SwiftUI

struct SkipSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let barWidth = min(w, h) * 0.18
        let barHeight = min(w, h) * 0.90
        let barRect = CGRect(x: center.x - barWidth/2,
                             y: center.y - barHeight/2,
                             width: barWidth,
                             height: barHeight)
        var rounded = Path(roundedRect: barRect, cornerRadius: barWidth/2)

        var t = CGAffineTransform(translationX: -center.x, y: -center.y)
        rounded = rounded.applying(t)
        t = CGAffineTransform(rotationAngle: -CGFloat.pi/4)
        rounded = rounded.applying(t)
        t = CGAffineTransform(translationX: center.x, y: center.y)
        rounded = rounded.applying(t)

        return rounded
    }
}
