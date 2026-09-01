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

struct EmphasizedButtonHoverEffect: CustomHoverEffect {
  func body(content: Content) -> some CustomHoverEffect {
    content
      .hoverEffect(.highlight)
      .hoverEffect { effect, isActive, _ in
        effect.animation(.easeOut(duration: 0.15)) {
          $0.scaleEffect(isActive ? 1.12 : 1)
        }
      }
  }
}

struct ObviousHoverButton: View {
  let title: String
  let prominent: Bool
  let action: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: action) {
      Text(title)
        .frame(maxWidth: .infinity, minHeight: 64)
        .foregroundStyle(isHovered ? .black : .primary)
        .background {
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(isHovered ? Color.white : (prominent ? Color.accentColor : Color.clear))
            .shadow(color: isHovered ? .white.opacity(0.95) : .clear, radius: 28)
        }
        .overlay {
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(.white.opacity(isHovered ? 1 : 0.25), lineWidth: isHovered ? 5 : 1)
        }
    }
    .buttonStyle(.plain)
    .hoverEffect(EmphasizedButtonHoverEffect())
    .onHover { isHovered = $0 }
  }
}

struct ReproMenu: View {
  let model: ReproModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Actions received: \(model.actionCount)")
        .font(.title2.monospacedDigit())
      ObviousHoverButton(title: "Test Action", prominent: true) {
        model.actionCount += 1
        model.lastAction = Date.now.formatted(date: .omitted, time: .standard)
        print(
          "[Repro] Test Action fired at \(model.lastAction), count = \(model.actionCount)"
        )
      }
      ObviousHoverButton(title: "Clear Count and Close", prominent: false) {
        let now = Date.now
        model.actionCount = 0
        model.lastAction = "Count cleared before closing"
        model.closeRequestedAt = now
        print("[Repro] Clear Count and Close action fired at \(now.timeIntervalSince1970)")
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
  @State private var presentationAnchor: Entity?

  var body: some View {
    RealityView { content in
      let anchor = Entity()
      anchor.name = "PRESENTATION_ANCHOR"
      anchor.position = [0, -0.399, 0.35]

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
      presentationAnchor = anchor

      let frontCard = ModelEntity(
        mesh: .generateBox(width: 0.064, height: 0.002, depth: 0.089),
        materials: [SimpleMaterial(color: .red, isMetallic: false)]
      )
      frontCard.name = "FRONT_RED_CARD"
      frontCard.position = [0, -0.499, 0.35]
      frontCard.generateCollisionShapes(recursive: false)
      frontCard.components.set(InputTargetComponent())
      frontCard.components.set(HoverEffectComponent())
      content.add(frontCard)

      let backCard = ModelEntity(
        mesh: .generateBox(width: 0.064, height: 0.002, depth: 0.089),
        materials: [SimpleMaterial(color: .blue, isMetallic: false)]
      )
      backCard.name = "BACK_BLUE_CARD"
      backCard.position = [0, -0.499, -0.35]
      backCard.generateCollisionShapes(recursive: false)
      backCard.components.set(InputTargetComponent())
      backCard.components.set(HoverEffectComponent())
      content.add(backCard)

      let instructionsMesh = MeshResource.generateText(
          """
          tap on a card

          1. standing at red card's side, right hand does not block anything.
          2. standing at blue card's side, right hand blocks both presentation's button gaze and auto closes on hand movement
          """,
          extrusionDepth: 0.0005,
          font: .systemFont(ofSize: 0.048, weight: .medium),
          containerFrame: CGRect(x: -0.42, y: 0, width: 0.84, height: 0.60),
          alignment: .left,
          lineBreakMode: .byWordWrapping
        )
      let instructionsPlaque = ModelEntity(
        mesh: .generateBox(width: 0.88, height: 0.001, depth: 0.62),
        materials: [SimpleMaterial(color: .darkGray, isMetallic: false)]
      )
      instructionsPlaque.name = "FLOOR_INSTRUCTIONS_PLAQUE"
      instructionsPlaque.position = [0, -0.4995, 0]
      content.add(instructionsPlaque)

      let instructions = ModelEntity(
        mesh: instructionsMesh,
        materials: [SimpleMaterial(color: .white, isMetallic: false)]
      )
      instructions.name = "FLOOR_INSTRUCTIONS"
      instructions.position = [0, -0.499, 0.30]
      instructions.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
      content.add(instructions)

    }
    .gesture(
      TapGesture()
        .targetedToEntity(where: .has(InputTargetComponent.self))
        .onEnded { value in
          guard ["FRONT_RED_CARD", "BACK_BLUE_CARD"].contains(value.entity.name) else {
            return
          }
          guard let presentationAnchor else { return }
          print("[Repro] \(value.entity.name) tapped; resetting presentation")
          model.isPresented = false
          presentationAnchor.position = value.entity.position + [0, 0.1, 0]
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
    }
    .windowStyle(.volumetric)
    .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
  }
}
