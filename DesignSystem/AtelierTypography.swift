import SwiftUI

enum AtelierType {
    // Editorial — the splash "Atelier" text. A statement.
    static let editorial = Font.system(size: 72, weight: .ultraLight, design: .serif)

    // Display — canvas titles. Large, light, deliberate.
    static let display = Font.system(size: 48, weight: .light, design: .default)

    // Title — section headings within a canvas.
    static let title = Font.system(size: 28, weight: .regular, design: .default)

    // Body — main text content. Readable, warm.
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    // Body small — secondary text, editorial notes.
    static let bodySmall = Font.system(size: 15, weight: .regular, design: .default)

    // Caption — metadata, timestamps. Precise, small.
    static let caption = Font.system(size: 12, weight: .medium, design: .default)

    // Mono — waveform timestamps, technical labels. Archival.
    static let mono = Font.system(size: 11, weight: .regular, design: .monospaced)

    // Shelf card title
    static let cardTitle = Font.system(size: 20, weight: .regular, design: .default)

    // Toolbar labels
    static let toolbar = Font.system(size: 13, weight: .medium, design: .default)
}

// Tracking (letter-spacing) modifiers
extension View {
    func atelierTracking(_ value: CGFloat = -0.3) -> some View {
        self.tracking(value)
    }

    func atelierTrackingWide() -> some View {
        self.tracking(1.5)
    }
}
