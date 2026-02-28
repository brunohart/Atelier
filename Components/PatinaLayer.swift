import SwiftUI

/// A canvas overlay that accumulates faint traces of every touch interaction.
/// Like well-worn paper that remembers where hands have been.
/// Translates the "patina" pillar from Bruno's craft philosophy into SwiftUI.
struct PatinaLayer: View {
    @State private var marks: [PatinaMark] = []

    var body: some View {
        Canvas { context, size in
            for mark in marks {
                let age = min(mark.age, 1.0)
                let alpha = mark.intensity * (0.3 + age * 0.7)

                let rect = CGRect(
                    x: mark.x - mark.radius,
                    y: mark.y - mark.radius,
                    width: mark.radius * 2,
                    height: mark.radius * 2
                )

                context.opacity = alpha
                context.fill(
                    Ellipse().path(in: rect),
                    with: .color(mark.isAccent ? AtelierColors.burntOrange : AtelierColors.ink)
                )
            }
        }
        .allowsHitTesting(false)
    }

    /// Record a touch at this position. Called from parent views on gestures.
    func recordTouch(at point: CGPoint, isAccent: Bool = false) {
        let mark = PatinaMark(
            x: point.x,
            y: point.y,
            radius: isAccent ? Double.random(in: 10...18) : Double.random(in: 4...8),
            intensity: isAccent ? 0.04 : 0.015,
            isAccent: isAccent,
            age: 0
        )
        marks.append(mark)

        // Cap total marks for performance
        if marks.count > 200 {
            marks.removeFirst(marks.count - 200)
        }
    }
}

struct PatinaMark: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let radius: Double
    let intensity: Double
    let isAccent: Bool
    var age: Double
}
