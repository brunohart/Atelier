import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class CanvasViewModel {
    var canvas: AtelierCanvas
    var draggedBlockID: UUID?
    var isShowingAddMenu: Bool = false

    // Canvas viewport offset for panning
    var canvasOffset: CGSize = .zero
    var canvasDragOffset: CGSize = .zero

    init(canvas: AtelierCanvas) {
        self.canvas = canvas
    }

    var sortedTextBlocks: [TextBlock] {
        canvas.textBlocks.sorted { $0.sortOrder < $1.sortOrder }
    }

    var hasWaveform: Bool {
        canvas.waveformAmplitudes != nil
    }

    var hasSketch: Bool {
        canvas.sketchData != nil
    }

    func addTextBlock(content: String, isTitle: Bool = false) {
        // Place at center of viewport (offset by canvas pan)
        let centerX = 180.0 - Double(canvasOffset.width + canvasDragOffset.width)
        let centerY = 400.0 - Double(canvasOffset.height + canvasDragOffset.height)

        let block = TextBlock(
            content: content,
            positionX: centerX,
            positionY: centerY,
            fontSize: isTitle ? 48 : 17,
            fontWeight: isTitle ? "light" : "regular",
            isTitle: isTitle,
            sortOrder: canvas.textBlocks.count
        )
        block.canvas = canvas
        canvas.textBlocks.append(block)
        canvas.modifiedAt = .now
    }

    func updateTextBlock(_ block: TextBlock, content: String) {
        block.content = content
        canvas.modifiedAt = .now
    }

    func moveBlock(_ block: TextBlock, to position: CGPoint) {
        block.positionX = Double(position.x)
        block.positionY = Double(position.y)
        canvas.modifiedAt = .now
    }

    func deleteTextBlock(_ block: TextBlock) {
        canvas.textBlocks.removeAll { $0.id == block.id }
        canvas.modifiedAt = .now
    }
}
