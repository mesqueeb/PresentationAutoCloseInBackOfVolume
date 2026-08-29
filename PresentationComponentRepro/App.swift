import Foundation
import Observation
import RealityKit
import SwiftUI

@MainActor @Observable
final class ReproModel {
  var isPresented = false {
    didSet { print("[Repro] isPresented = \(isPresented)") }
  }
  var actionCount = 0
  var lastAction = "Never"
  var closeRequestedAt: Date?
  var lastCloseLatency = "Not measured"
}

struct ReproMenu: View {
  let model: ReproModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Lower-back presentation")
        .font(.headline)
      Text("Move your right hand near the floor, then look at Test Action.")
      Text("Actions received: \(model.actionCount)")
        .font(.title2.monospacedDigit())
      Text("Last action: \(model.lastAction)")
        .font(.caption.monospacedDigit())
      Text("Last close latency: \(model.lastCloseLatency)")
        .font(.caption.monospacedDigit())
      Button("Test Action") {
        model.actionCount += 1
        model.lastAction = Date.now.formatted(date: .omitted, time: .standard)
        print(
          "[Repro] Test Action fired at \(model.lastAction), count = \(model.actionCount)"
        )
      }
      .buttonStyle(.borderedProminent)
      Button("Close Menu") {
        let now = Date.now
        model.closeRequestedAt = now
        print("[Repro] Close action fired at \(now.timeIntervalSince1970)")
        model.isPresented = false
      }
    }
    .frame(width: 320)
    .padding(24)
    .glassBackgroundEffect()
    .onAppear { print("[Repro] menu appeared") }
    .onDisappear {
      let now = Date.now
      if let closeRequestedAt = model.closeRequestedAt {
        let latency = now.timeIntervalSince(closeRequestedAt)
        model.lastCloseLatency = String(format: "%.3f seconds", latency)
        model.closeRequestedAt = nil
        print(
          "[Repro] menu disappeared at \(now.timeIntervalSince1970); close latency = \(model.lastCloseLatency)"
        )
      } else {
        print(
          "[Repro] menu disappeared at \(now.timeIntervalSince1970) without Close action"
        )
      }
    }
  }
}

struct ReproVolume: View {
  @State private var model = ReproModel()

  var body: some View {
    RealityView { content in
      let anchor = Entity()
      anchor.name = "PRESENTATION_ANCHOR"
      anchor.position = [0.22, -0.44, -0.22]

      let binding = Binding(
        get: { model.isPresented },
        set: { model.isPresented = $0 }
      )
      anchor.components.set(
        PresentationComponent(
          isPresented: binding,
          configuration: .popover(arrowEdge: .bottom),
          content: ReproMenu(model: model)
        )
      )
      content.add(anchor)

      let opener = ModelEntity(
        mesh: .generateBox(width: 0.12, height: 0.008, depth: 0.08),
        materials: [SimpleMaterial(color: .blue, isMetallic: false)]
      )
      opener.name = "MENU_OPENER"
      opener.position = anchor.position
      opener.generateCollisionShapes(recursive: false)
      opener.components.set(InputTargetComponent())
      opener.components.set(HoverEffectComponent())
      content.add(opener)

      Task { @MainActor in
        await Task.yield()
        model.isPresented = true
      }
    }
    .gesture(
      TapGesture()
        .targetedToEntity(where: .has(InputTargetComponent.self))
        .onEnded { value in
          guard value.entity.name == "MENU_OPENER" else { return }
          print("[Repro] opener tapped; resetting presentation")
          model.isPresented = false
          Task { @MainActor in
            await Task.yield()
            model.isPresented = true
          }
        }
    )
    .onAppear { print("[Repro] volume appeared") }
    .volumeBaseplateVisibility(.hidden)
  }
}

@main
struct PresentationComponentReproApp: App {
  var body: some SwiftUI.Scene {
    WindowGroup {
      ReproVolume()
        .frame(width: 1360, height: 1360)
        .frame(depth: 1020)
    }
    .windowStyle(.volumetric)
    .windowResizability(.contentSize)
    .defaultSize(width: 1.0, height: 1.0, depth: 0.75, in: .meters)
  }
}
