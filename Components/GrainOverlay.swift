import SwiftUI

struct GrainOverlay: View {
    var opacity: Double = 0.04

    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 6
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    let noise = Double.random(in: 0.01...opacity)
                    let rect = CGRect(x: x, y: y, width: 1.5, height: 1.5)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.black.opacity(noise))
                    )
                    y += spacing
                }
                x += spacing
            }
        }
        .allowsHitTesting(false)
        .blendMode(.multiply)
    }
}
