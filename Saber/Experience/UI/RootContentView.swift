//
//  RootContentView.swift
//  Saber
//
//  Created by tamakou on 2025/10/19.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct RootContentView: View {

    @Environment(AppState.self) private var appState
    @Environment(RootCoordinator.self) private var coordinator
    @State private var isExpanded = false

    var body: some View {
        RealityView { content in
            if content.entities.isEmpty {
                if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                    content.add(scene)
                }
            }
        } update: { content in
            guard let scene = content.entities.first else { return }
            let scale: Float = isExpanded ? 1.35 : 1.0
            scene.transform.scale = [scale, scale, scale]
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            isExpanded.toggle()
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack(spacing: 12) {
                    BattleHUD()

                    Button {
                        isExpanded.toggle()
                    } label: {
                        Text(isExpanded ? "Scale Reset" : "Scale Up")
                    }
                    .buttonStyle(.borderedProminent)

                    inputPipelineStatusLabel

                    ImmersiveSpaceToggle()
                }
                .padding(.vertical, 16)
            }
        }
    }

    private var inputPipelineStatusLabel: some View {
        let statusText: String
        let color: Color
        switch appState.inputPipelineStatus {
        case .stopped:
            statusText = "Hand Tracking: Stopped"
            color = .gray
        case .starting:
            statusText = "Hand Tracking: Starting..."
            color = .orange
        case .running:
            statusText = "Hand Tracking: Live"
            color = .green
        case .failed:
            statusText = "Hand Tracking: Failed"
            color = .red
        }
        return Label(statusText, systemImage: "waveform.path.ecg")
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.2), in: Capsule())
    }
}

#Preview(windowStyle: .volumetric) {
    RootContentView()
        .environment(AppState())
        .environment(RootCoordinator())
}
