import SwiftUI

struct AudioWaveformView: View {
    let amplitudes: [Float]
    @State private var playheadProgress: CGFloat = 0
    @State private var isPlaying = false
    @State private var playbackTask: Task<Void, Never>?
    @State private var isScrubbing = false
    @State private var scrubPosition: CGFloat = 0  // 0...1 normalized
    @State private var touchX: CGFloat? = nil       // For proximity expansion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("AUDIO")
                .font(AtelierType.mono)
                .foregroundStyle(AtelierColors.warmGray)
                .tracking(1.5)

            // Waveform bars with scrub + proximity
            GeometryReader { geo in
                HStack(alignment: .center, spacing: 2) {
                    ForEach(Array(amplitudes.enumerated()), id: \.offset) { index, amp in
                        let normalized = CGFloat(amp)
                        let barPosition = CGFloat(index) / CGFloat(max(amplitudes.count - 1, 1))
                        let progress = isScrubbing ? scrubPosition : playheadProgress
                        let isPast = barPosition < progress

                        // Proximity expansion — bars near touch point grow taller
                        let proximityScale = proximityScale(
                            barIndex: index,
                            totalBars: amplitudes.count,
                            geoWidth: geo.size.width
                        )

                        RoundedRectangle(cornerRadius: 1)
                            .fill(isPast ? AtelierColors.burntOrange : AtelierColors.ink.opacity(0.25))
                            .frame(
                                width: max(2, (geo.size.width / CGFloat(amplitudes.count)) - 2),
                                height: max(4, normalized * geo.size.height * 0.9 * proximityScale)
                            )
                            .animation(AtelierSpring.light, value: touchX)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let normalized = max(0, min(1, value.location.x / geo.size.width))
                            if !isScrubbing {
                                isScrubbing = true
                                playbackTask?.cancel()
                                isPlaying = false
                                AtelierHaptics.shared.friction()
                            }
                            scrubPosition = normalized
                            touchX = value.location.x
                        }
                        .onEnded { value in
                            let normalized = max(0, min(1, value.location.x / geo.size.width))
                            playheadProgress = normalized
                            isScrubbing = false
                            touchX = nil
                            AtelierHaptics.shared.settle()
                        }
                )
            }
            .frame(height: 56)
            .onTapGesture {
                togglePlayback()
            }

            // Duration label
            HStack {
                Text(statusText)
                    .font(AtelierType.mono)
                    .foregroundStyle(AtelierColors.warmGray)
                Spacer()
                Text("0:32")
                    .font(AtelierType.mono)
                    .foregroundStyle(AtelierColors.warmGray)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AtelierColors.cream.opacity(0.6))
                .shadow(color: AtelierColors.cardShadow, radius: 8, y: 2)
        )
    }

    private var statusText: String {
        if isScrubbing { return "Scrubbing..." }
        if isPlaying { return "Playing..." }
        return "Tap to preview"
    }

    // MARK: - Proximity Scale

    private func proximityScale(barIndex: Int, totalBars: Int, geoWidth: CGFloat) -> CGFloat {
        guard let tx = touchX else { return 1.0 }
        let barWidth = geoWidth / CGFloat(totalBars)
        let barCenter = CGFloat(barIndex) * barWidth + barWidth / 2
        let distance = abs(barCenter - tx)
        let maxDistance: CGFloat = 60
        let closeness = max(0, 1 - distance / maxDistance)
        return 1.0 + closeness * 0.35  // Up to 35% taller near touch
    }

    // MARK: - Playback

    private func togglePlayback() {
        AtelierHaptics.shared.tap()
        if isPlaying {
            playbackTask?.cancel()
            isPlaying = false
            withAnimation(AtelierSpring.settle) {
                playheadProgress = 0
            }
        } else {
            isPlaying = true
            playheadProgress = 0
            withAnimation(.linear(duration: 3.0)) {
                playheadProgress = 1.0
            }
            playbackTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(3200))
                guard !Task.isCancelled else { return }
                isPlaying = false
                withAnimation(AtelierSpring.settle) {
                    playheadProgress = 0
                }
            }
        }
    }
}
