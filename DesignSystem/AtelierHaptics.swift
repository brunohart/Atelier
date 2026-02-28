import CoreHaptics
import UIKit

@MainActor
final class AtelierHaptics {
    static let shared = AtelierHaptics()

    private var engine: CHHapticEngine?

    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
        engine?.resetHandler = { [weak self] in
            Task { @MainActor in
                try? self?.engine?.start()
            }
        }
    }

    // Pillar: Weight — picking up a canvas card, landing on shelf
    func weight() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.8)
    }

    // Pillar: Friction — page turn commit, crossing a threshold
    func friction() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.5)
    }

    // Pillar: Tactility — button press, text block tap
    func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
    }

    // Pillar: Resistance — edge bounce, no more pages
    func resistance() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    // Pillar: Silence — completion, settling into place
    func settle() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // Splash — the opening impression
    func splashReveal() {
        guard let engine else { return }
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [sharpness, intensity],
            relativeTime: 0
        )
        guard let pattern = try? CHHapticPattern(events: [event], parameters: []) else { return }
        let player = try? engine.makePlayer(with: pattern)
        try? player?.start(atTime: CHHapticTimeImmediate)
    }
}
