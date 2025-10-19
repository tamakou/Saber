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
                    Button {
                        isExpanded.toggle()
                    } label: {
                        Text(isExpanded ? "Scale Reset" : "Scale Up")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        coordinator.swapToPSVR2IfAvailable()
                    } label: {
                        Text("Pair PSVR2 Sense")
                    }
                    .buttonStyle(.bordered)

                    ImmersiveSpaceToggle()
                }
                .padding(.vertical, 16)
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    RootContentView()
        .environment(AppState())
        .environment(RootCoordinator())
}
