import SwiftUI
import SwiftData

struct ShelfView: View {
    let namespace: Namespace.ID
    var onSelectCanvas: (Int) -> Void

    @Query(sort: \AtelierCanvas.sortOrder) private var canvases: [AtelierCanvas]
    @Environment(\.modelContext) private var modelContext

    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 360), spacing: 24)
    ]

    var body: some View {
        ZStack {
            AtelierColors.deepParchment
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Atelier")
                            .font(AtelierType.display)
                            .foregroundStyle(AtelierColors.ink)
                            .tracking(-0.5)

                        Text("\(canvases.count) CANVASES")
                            .font(AtelierType.mono)
                            .foregroundStyle(AtelierColors.warmGray)
                            .tracking(1.5)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 32)

                    // Canvas grid
                    LazyVGrid(columns: columns, spacing: 28) {
                        ForEach(Array(canvases.enumerated()), id: \.element.id) { index, canvas in
                            CanvasCardView(
                                canvas: canvas,
                                namespace: namespace,
                                onTap: {
                                    onSelectCanvas(index)
                                }
                            )
                        }

                        // Add canvas card
                        AddCanvasCard {
                            addNewCanvas()
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }

            GrainOverlay(opacity: 0.03)
                .ignoresSafeArea()
        }
    }

    private func addNewCanvas() {
        let canvas = AtelierCanvas(
            title: "Untitled",
            sortOrder: canvases.count
        )
        modelContext.insert(canvas)
        AtelierHaptics.shared.tap()
    }
}

struct AddCanvasCard: View {
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                AtelierColors.parchment.opacity(0.5)

                VStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(AtelierColors.warmGray)

                    Text("NEW CANVAS")
                        .font(AtelierType.mono)
                        .foregroundStyle(AtelierColors.warmGray)
                        .tracking(1.5)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(AtelierColors.warmGray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            )

            // Spacer for metadata alignment
            HStack {
                Text(" ")
                    .font(AtelierType.caption)
            }
        }
        .onTapGesture {
            AtelierHaptics.shared.tap()
            onTap()
        }
    }
}
