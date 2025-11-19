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
            Circle().inset(by: 9.5).stroke(.white, lineWidth: 2)
            Text(isHi ? "HI" : "LO")
                .font(.system(size: 49, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 142, height: 142)
        .accessibilityLabel(isHi ? "High token" : "Low token")
    }
}

#Preview("Token HI") { TokenView(isHi: true) }
#Preview("Token LO") { TokenView(isHi: false) }
