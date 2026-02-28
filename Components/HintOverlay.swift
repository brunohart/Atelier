import SwiftUI

/// Subtle, non-modal hints that teach the freeform interaction model.
/// Each hint shows once, tracked via @AppStorage.
struct HintOverlay: View {
    @AppStorage("hint_drag_shown") private var dragHintShown = false
    @AppStorage("hint_swipe_shown") private var swipeHintShown = false

    @State private var showDragHint = false
    @State private var showSwipeHint = false

    var body: some View {
        ZStack {
            // Drag hint near center
            if showDragHint {
                hintBadge("Hold and drag to arrange")
                    .position(x: 200, y: 300)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .allowsHitTesting(false)
        .task {
            await showHints()
        }
    }

    private func hintBadge(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AtelierType.mono)
            .foregroundStyle(AtelierColors.warmGray)
            .tracking(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(AtelierColors.cream.opacity(0.95))
                    .shadow(color: AtelierColors.cardShadow, radius: 8, y: 2)
            )
    }

    private func showHints() async {
        // Show drag hint after entry animation completes
        if !dragHintShown {
            try? await Task.sleep(for: .milliseconds(2000))
            withAnimation(AtelierSpring.reveal) {
                showDragHint = true
            }
            dragHintShown = true

            // Auto-dismiss after 3 seconds
            try? await Task.sleep(for: .milliseconds(3000))
            withAnimation(AtelierSpring.settle) {
                showDragHint = false
            }
        }
    }
}
