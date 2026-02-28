import SwiftUI
import SwiftData

@MainActor
@Observable
final class ShelfViewModel {
    var selectedCanvasIndex: Int?
    var isDraggingCard: Bool = false
    var draggedCanvasId: UUID?

    func reorderCanvases(_ canvases: [AtelierCanvas], from source: IndexSet, to destination: Int) {
        var ordered = canvases
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, canvas) in ordered.enumerated() {
            canvas.sortOrder = index
        }
        AtelierHaptics.shared.settle()
    }
}
