//
//  TokenView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 9/15/25.
//

import SwiftUI

struct TokenView: View {
    var isHi: Bool

    var body: some View {
        ZStack {
            Circle().fill(.black)
            Circle().inset(by: 10).stroke(.white, lineWidth: 2)
            Text(isHi ? "HI" : "LO")
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 150, height: 150)
        .accessibilityLabel(isHi ? "High token" : "Low token")
    }
}

#Preview("Token HI") { TokenView(isHi: true) }
#Preview("Token LO") { TokenView(isHi: false) }
