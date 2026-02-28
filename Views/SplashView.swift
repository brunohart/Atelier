import SwiftUI

struct SplashView: View {
    var onComplete: () -> Void

    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 12
    @State private var lineWidth: CGFloat = 0
    @State private var grainOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        ZStack {
            AtelierColors.parchment
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // The name. A statement.
                Text("Atelier")
                    .font(AtelierType.editorial)
                    .foregroundStyle(AtelierColors.ink)
                    .tracking(-1)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                // Registration mark — burnt orange accent line
                Rectangle()
                    .fill(AtelierColors.burntOrange)
                    .frame(width: lineWidth, height: 1.5)
                    .opacity(lineWidth > 0 ? 1 : 0)

                // Subtitle
                Text("A creative instrument")
                    .font(AtelierType.caption)
                    .foregroundStyle(AtelierColors.warmGray)
                    .tracking(2)
                    .textCase(.uppercase)
                    .opacity(subtitleOpacity)
            }

            GrainOverlay(opacity: 0.03)
                .opacity(grainOpacity)
        }
        .task {
            AtelierHaptics.shared.prepare()

            // Step 1: Title fades in, rises (300ms delay)
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(AtelierSpring.reveal) {
                titleOpacity = 1
                titleOffset = 0
            }
            AtelierHaptics.shared.splashReveal()

            // Step 2: Accent line draws (500ms later)
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeOut(duration: 0.6)) {
                lineWidth = 60
            }

            // Step 3: Subtitle appears (400ms later)
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(AtelierSpring.reveal) {
                subtitleOpacity = 1
            }

            // Step 4: Grain fades in (300ms later)
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.easeIn(duration: 0.4)) {
                grainOpacity = 1
            }

            // Complete after remaining time
            try? await Task.sleep(for: .milliseconds(1000))
            onComplete()
        }
    }
}
