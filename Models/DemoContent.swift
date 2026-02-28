import SwiftData
import PencilKit
import UIKit

enum DemoContent {

    @MainActor
    static func createAllCanvases(in context: ModelContext) {
        createMusicianCanvas(in: context)
        createWriterCanvas(in: context)
        createArchitectCanvas(in: context)
    }

    // MARK: - Canvas 1: Musician's Session Notes

    @MainActor
    static func createMusicianCanvas(in context: ModelContext) {
        let canvas = AtelierCanvas(
            title: "Late Night Session",
            sortOrder: 0,
            waveformAmplitudes: generateWaveform(),
            waveformDuration: 32
        )
        context.insert(canvas)

        let title = TextBlock(
            content: "Late Night Session",
            positionX: 40,
            positionY: 80,
            fontSize: 48,
            fontWeight: "light",
            isTitle: true,
            sortOrder: 0
        )
        title.canvas = canvas

        let date = TextBlock(
            content: "FEB 2026 — DEMO TAPE 03",
            positionX: 44,
            positionY: 140,
            width: 400,
            fontSize: 11,
            fontWeight: "medium",
            isTitle: false,
            sortOrder: 1
        )
        date.canvas = canvas

        let notes = TextBlock(
            content: "The bridge needs reworking. E minor to A — too predictable. Try the chromatic walk from the demo tape. The second take had something in the verse — that hesitation before the chord change. Keep it.\n\nRemember: silence is louder than the chorus.",
            positionX: 40,
            positionY: 200,
            width: 480,
            fontSize: 17,
            fontWeight: "regular",
            isTitle: false,
            sortOrder: 2
        )
        notes.canvas = canvas

        // This note is placed off to the right — freeform arrangement
        let aside = TextBlock(
            content: "Ask Maya about the string arrangement.\nShe mentioned something about leaving space —\nletting the cello breathe between phrases.",
            positionX: 40,
            positionY: 520,
            width: 380,
            fontSize: 15,
            fontWeight: "regular",
            isTitle: false,
            sortOrder: 3
        )
        aside.canvas = canvas

        context.insert(title)
        context.insert(date)
        context.insert(notes)
        context.insert(aside)
    }

    // MARK: - Canvas 2: Writer's Draft

    @MainActor
    static func createWriterCanvas(in context: ModelContext) {
        let canvas = AtelierCanvas(
            title: "Chapter Opening",
            sortOrder: 1
        )
        context.insert(canvas)

        let title = TextBlock(
            content: "Chapter Opening",
            positionX: 40,
            positionY: 80,
            fontSize: 48,
            fontWeight: "light",
            isTitle: true,
            sortOrder: 0
        )
        title.canvas = canvas

        let prose = TextBlock(
            content: "The rain had been falling for three days when she finally opened the studio. Not the gentle kind that makes you want to read — the heavy, indifferent kind that erases the line between sky and street. The windows were fogged from the inside, and the smell of turpentine had settled into everything: the floorboards, the curtains, the collar of his coat still hanging by the door.",
            positionX: 40,
            positionY: 160,
            width: 520,
            fontSize: 17,
            fontWeight: "regular",
            isTitle: false,
            sortOrder: 1
        )
        prose.canvas = canvas

        // Editorial note — placed like a sticky note, slightly offset
        let note = TextBlock(
            content: "Cut the first sentence. Start with the weather as action, not observation. The studio should feel like it's been waiting.",
            positionX: 60,
            positionY: 380,
            width: 360,
            fontSize: 13,
            fontWeight: "medium",
            isTitle: false,
            sortOrder: 2
        )
        note.canvas = canvas

        let secondDraft = TextBlock(
            content: "Three days of rain, and the studio was waiting. She turned the key and the door gave way — not opened, gave way — and the smell hit her before the light did. Turpentine and dust and the faint ghost of his cologne, still soaked into the coat by the door.",
            positionX: 40,
            positionY: 480,
            width: 520,
            fontSize: 17,
            fontWeight: "regular",
            isTitle: false,
            sortOrder: 3
        )
        secondDraft.canvas = canvas

        context.insert(title)
        context.insert(prose)
        context.insert(note)
        context.insert(secondDraft)
    }

    // MARK: - Canvas 3: Architect's Site Visit

    @MainActor
    static func createArchitectCanvas(in context: ModelContext) {
        let canvas = AtelierCanvas(
            title: "Courtyard Measurements",
            sortOrder: 2,
            sketchData: generateArchitectSketch()
        )
        context.insert(canvas)

        let title = TextBlock(
            content: "Courtyard Measurements",
            positionX: 40,
            positionY: 80,
            fontSize: 48,
            fontWeight: "light",
            isTitle: true,
            sortOrder: 0
        )
        title.canvas = canvas

        let date = TextBlock(
            content: "SITE VISIT — 27 FEB 2026",
            positionX: 44,
            positionY: 140,
            width: 400,
            fontSize: 11,
            fontWeight: "medium",
            isTitle: false,
            sortOrder: 1
        )
        date.canvas = canvas

        let notes = TextBlock(
            content: "North wall: 8.2m. The existing foundation extends 40cm past the visible edge — check with structural before committing to the column spacing.\n\nThe light at 3pm is extraordinary. The courtyard acts as a light well — the west wall gets direct sun for roughly two hours. Design the reading alcove there.",
            positionX: 40,
            positionY: 200,
            width: 460,
            fontSize: 17,
            fontWeight: "regular",
            isTitle: false,
            sortOrder: 2
        )
        notes.canvas = canvas

        let annotation = TextBlock(
            content: "Sketch below is approximate.\nReal measurements pending surveyor report.",
            positionX: 40,
            positionY: 400,
            width: 360,
            fontSize: 13,
            fontWeight: "medium",
            isTitle: false,
            sortOrder: 3
        )
        annotation.canvas = canvas

        context.insert(title)
        context.insert(date)
        context.insert(notes)
        context.insert(annotation)
    }

    // MARK: - Generators

    static func generateWaveform() -> [Float] {
        (0..<120).map { i in
            let t = Float(i) / 120.0
            let base = sin(t * .pi * 4) * 0.3
            let detail = sin(t * .pi * 17) * 0.15
            let accent = sin(t * .pi * 7.3) * 0.1
            let envelope = sin(t * .pi) * 0.85
            let noise = Float.random(in: 0...0.08)
            return max(0.05, min(1.0, abs(base + detail + accent) * envelope + noise))
        }
    }

    @MainActor
    static func generateArchitectSketch() -> Data? {
        var strokes: [PKStroke] = []
        let ink = PKInk(.pen, color: UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 0.7))

        // Rectangle representing courtyard
        let rectPoints: [(CGFloat, CGFloat)] = [
            (100, 460), (500, 460), (500, 660), (100, 660), (100, 460)
        ]
        if let rectStroke = makeStroke(points: rectPoints, ink: ink, width: 2.0) {
            strokes.append(rectStroke)
        }

        // North wall label line
        let northLine: [(CGFloat, CGFloat)] = [(100, 450), (500, 450)]
        if let stroke = makeStroke(points: northLine, ink: ink, width: 1.0) {
            strokes.append(stroke)
        }

        // Dimension ticks
        let tickLeft: [(CGFloat, CGFloat)] = [(100, 445), (100, 455)]
        let tickRight: [(CGFloat, CGFloat)] = [(500, 445), (500, 455)]
        if let s1 = makeStroke(points: tickLeft, ink: ink, width: 1.5) { strokes.append(s1) }
        if let s2 = makeStroke(points: tickRight, ink: ink, width: 1.5) { strokes.append(s2) }

        // Column marks inside courtyard
        let col1: [(CGFloat, CGFloat)] = [(200, 460), (200, 480)]
        let col2: [(CGFloat, CGFloat)] = [(300, 460), (300, 480)]
        let col3: [(CGFloat, CGFloat)] = [(400, 460), (400, 480)]
        if let s = makeStroke(points: col1, ink: ink, width: 1.5) { strokes.append(s) }
        if let s = makeStroke(points: col2, ink: ink, width: 1.5) { strokes.append(s) }
        if let s = makeStroke(points: col3, ink: ink, width: 1.5) { strokes.append(s) }

        // Alcove sketch on west wall
        let alcove: [(CGFloat, CGFloat)] = [
            (80, 540), (100, 540), (100, 600), (80, 600), (80, 540)
        ]
        if let s = makeStroke(points: alcove, ink: ink, width: 1.5) { strokes.append(s) }

        // Sun direction arrow
        let sunArrow: [(CGFloat, CGFloat)] = [(520, 480), (460, 540)]
        if let s = makeStroke(points: sunArrow, ink: PKInk(.pen, color: UIColor(red: 212/255, green: 98/255, blue: 43/255, alpha: 0.5)), width: 1.5) {
            strokes.append(s)
        }

        let drawing = PKDrawing(strokes: strokes)
        return drawing.dataRepresentation()
    }

    private static func makeStroke(points: [(CGFloat, CGFloat)], ink: PKInk, width: CGFloat) -> PKStroke? {
        guard points.count >= 2 else { return nil }

        var strokePoints: [PKStrokePoint] = []
        for (i, point) in points.enumerated() {
            let t = CGFloat(i) / CGFloat(max(points.count - 1, 1))
            let strokePoint = PKStrokePoint(
                location: CGPoint(x: point.0, y: point.1),
                timeOffset: t * 0.5,
                size: CGSize(width: width, height: width),
                opacity: 1.0,
                force: 0.5,
                azimuth: 0,
                altitude: .pi / 2
            )
            strokePoints.append(strokePoint)
        }

        let path = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
        return PKStroke(ink: ink, path: path)
    }
}
