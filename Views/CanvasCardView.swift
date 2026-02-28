import SwiftUI

struct CanvasCardView: View {
    let canvas: AtelierCanvas
    let namespace: Namespace.ID
    var onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Canvas preview area
            ZStack(alignment: .topLeading) {
                AtelierColors.parchment

                VStack(alignment: .leading, spacing: 8) {
                    // Title preview
                    if let titleBlock = canvas.textBlocks.first(where: { $0.isTitle }) {
                        Text(titleBlock.content)
                            .font(AtelierType.cardTitle)
                            .foregroundStyle(AtelierColors.ink)
                            .lineLimit(2)
                    } else {
                        Text(canvas.title)
                            .font(AtelierType.cardTitle)
                            .foregroundStyle(AtelierColors.ink)
                            .lineLimit(2)
                    }

                    // Body preview
                    if let bodyBlock = canvas.textBlocks.first(where: { !$0.isTitle }) {
                        Text(bodyBlock.content)
                            .font(AtelierType.bodySmall)
                            .foregroundStyle(AtelierColors.ink.opacity(0.5))
                            .lineLimit(3)
                    }

                    // Waveform indicator
                    if canvas.waveformAmplitudes != nil {
                        MiniWaveformView(seed: canvas.id.hashValue)
                            .padding(.top, 4)
                    }

                    // Sketch indicator
                    if canvas.sketchData != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil.tip")
                                .font(.system(size: 10))
                            Text("SKETCH")
                                .font(AtelierType.mono)
                        }
                        .foregroundStyle(AtelierColors.warmGray)
                        .padding(.top, 4)
                    }

                    Spacer()
                }
                .padding(20)

                GrainOverlay(opacity: 0.02)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            // Metadata
            HStack {
                Text(canvas.title)
                    .font(AtelierType.caption)
                    .foregroundStyle(AtelierColors.warmGray)
                Spacer()
                Text(canvas.modifiedAt.formatted(.dateTime.month(.abbreviated).day()))
                    .font(AtelierType.mono)
                    .foregroundStyle(AtelierColors.warmGray.opacity(0.6))
            }
        }
        .matchedGeometryEffect(id: canvas.id, in: namespace)
        .rotationEffect(.degrees(canvas.rotation * 0.5))
        .shadow(color: AtelierColors.cardShadow, radius: isPressed ? 8 : 20, y: isPressed ? 2 : 6)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(AtelierSpring.light, value: isPressed)
        .onTapGesture {
            AtelierHaptics.shared.weight()
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct MiniWaveformView: View {
    let seed: Int

    private var heights: [CGFloat] {
        var rng = SeededRandom(seed: seed)
        return (0..<20).map { _ in
            CGFloat(rng.next()) * 12 + 4
        }
    }

    var body: some View {
        HStack(spacing: 1.5) {
            ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(AtelierColors.ink.opacity(0.15))
                    .frame(width: 2, height: height)
            }
        }
        .frame(height: 16)
    }
}

// Deterministic random for stable waveform thumbnails
private struct SeededRandom {
    private var state: UInt64

    init(seed: Int) {
        state = UInt64(bitPattern: Int64(seed))
        if state == 0 { state = 1 }
    }

    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double((state >> 33) & 0x7FFFFFFF) / Double(0x7FFFFFFF)
    }
}
