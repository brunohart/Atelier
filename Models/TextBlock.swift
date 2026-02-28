import SwiftData
import Foundation

@Model
final class TextBlock {
    var id: UUID
    var content: String
    var positionX: Double
    var positionY: Double
    var width: Double
    var fontSize: Double
    var fontWeight: String
    var isTitle: Bool
    var sortOrder: Int

    var canvas: AtelierCanvas?

    init(
        content: String,
        positionX: Double = 40,
        positionY: Double = 100,
        width: Double = 600,
        fontSize: Double = 17,
        fontWeight: String = "regular",
        isTitle: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.content = content
        self.positionX = positionX
        self.positionY = positionY
        self.width = width
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.isTitle = isTitle
        self.sortOrder = sortOrder
    }
}
