//
//  SettingsView.swift
//  HiLoFlip
//
//  Created by Aaron Hill on 11/4/25.
//

import SwiftUI
import Observation

struct SettingsView: View {
    @Bindable var vm: HiLoFlipCardGame
    
    var body: some View {
        Form {
            Section("Players") {
                ForEach(vm.playerNames.indices, id: \.self) { i in
                    TextField("Player \(i+1)", text: Binding(
                        get: { vm.playerNames[i] },
                        set: { new in
                            var names = vm.playerNames
                            names[i] = new
                            vm.playerNames = names
                        }
                    ))
                }
            }
        }
        .navigationTitle("Settings")
    }
}
