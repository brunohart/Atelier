import SwiftData
import Foundation

@Model
final class AtelierCanvas {
    var id: UUID
    var title: String
    var createdAt: Date
    var modifiedAt: Date
    var sortOrder: Int
    var rotation: Double

    @Relationship(deleteRule: .cascade, inverse: \TextBlock.canvas)
    var textBlocks: [TextBlock]

    var sketchData: Data?
    var waveformAmplitudes: [Float]?
    var waveformDuration: Double?

    init(
        title: String,
        sortOrder: Int,
        sketchData: Data? = nil,
        waveformAmplitudes: [Float]? = nil,
        waveformDuration: Double? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.createdAt = .now
        self.modifiedAt = .now
        self.sortOrder = sortOrder
        self.rotation = Double.random(in: -2.0...2.0)
        self.textBlocks = []
        self.sketchData = sketchData
        self.waveformAmplitudes = waveformAmplitudes
        self.waveformDuration = waveformDuration
    }
}
