//
//  ImmersiveSpaceToggle.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import SwiftUI

struct ImmersiveSpaceToggle: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button(action: toggleImmersiveSpace) {
            Text(buttonLabel)
        }
        .disabled(appState.immersiveSpaceState == .inTransition)
        .buttonStyle(.bordered)
    }

    private var buttonLabel: String {
        switch appState.immersiveSpaceState {
        case .open:
            return "Hide Immersive Space"
        case .closed:
            return "Show Immersive Space"
        case .inTransition:
            return "Loading..."
        }
    }

    private func toggleImmersiveSpace() {
        Task { @MainActor in
            switch appState.immersiveSpaceState {
            case .open:
                appState.markTransitionInProgress()
                await dismissImmersiveSpace()
            case .closed:
                appState.markTransitionInProgress()
                let result = await openImmersiveSpace(id: appState.immersiveSpaceID)
                if case .opened = result {
                    break
                } else {
                    appState.markImmersiveTransition(isOpen: false)
                }
            case .inTransition:
                break
            }
        }
    }
}

#Preview {
    ImmersiveSpaceToggle()
        .environment(AppState())
}
