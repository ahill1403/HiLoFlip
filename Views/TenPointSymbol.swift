//
//  TenPointSymbol.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 10/21/25.
//

import SwiftUI

struct TenPointSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cx = rect.midX
        let cy = rect.midY
        let radius = min(rect.width, rect.height) * 0.5
        let outerR = radius * 0.95
        let innerR = radius * 0.40

        let startAngle = -CGFloat.pi / 2
        for i in 0..<10 {
            let angle = startAngle + CGFloat(i) * (2 * .pi / 10)
            let r = (i % 2 == 0) ? outerR : innerR
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}
