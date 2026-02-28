import SwiftUI

struct TextBlockView: View {
    let block: TextBlock
    var onUpdate: ((String) -> Void)?
    var onMove: ((CGPoint) -> Void)?
    var isDragging: Bool = false

    @State private var isEditing = false
    @State private var editText: String = ""
    @State private var dragOffset: CGSize = .zero
    @State private var isLifted = false
    @State private var liftRotation: Double = 0

    private var font: Font {
        let size = block.fontSize
        let weight: Font.Weight = switch block.fontWeight {
        case "light": .light
        case "bold": .bold
        case "medium": .medium
        case "ultraLight": .ultraLight
        default: .regular
        }
        return .system(size: size, weight: weight, design: .default)
    }

    private var lineSpacing: CGFloat {
        block.isTitle ? 2 : 6
    }

    var body: some View {
        Group {
            if isEditing {
                TextField("", text: $editText, axis: .vertical)
                    .font(font)
                    .foregroundStyle(AtelierColors.ink)
                    .lineSpacing(lineSpacing)
                    .onSubmit {
                        isEditing = false
                        onUpdate?(editText)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AtelierColors.cream.opacity(0.5))
                    )
            } else {
                Text(block.content)
                    .font(font)
                    .foregroundStyle(block.isTitle ? AtelierColors.ink : AtelierColors.ink.opacity(0.85))
                    .lineSpacing(lineSpacing)
                    .tracking(block.isTitle ? -0.5 : 0)
                    .padding(8)
            }
        }
        .frame(width: block.width, alignment: .leading)
        .multilineTextAlignment(.leading)
        // Physics: lift when dragged
        .scaleEffect(isLifted ? 1.03 : 1.0)
        .rotationEffect(.degrees(isLifted ? liftRotation : 0))
        .shadow(
            color: AtelierColors.ink.opacity(isLifted ? 0.15 : 0.0),
            radius: isLifted ? 20 : 0,
            x: 0,
            y: isLifted ? 8 : 0
        )
        .offset(dragOffset)
        .animation(isLifted ? nil : AtelierSpring.heavy, value: dragOffset)
        .animation(AtelierSpring.light, value: isLifted)
        .onTapGesture {
            guard !isDragging else { return }
            editText = block.content
            isEditing = true
            AtelierHaptics.shared.tap()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.25)
                .sequenced(before: DragGesture(minimumDistance: 0))
                .onChanged { value in
                    switch value {
                    case .first(true):
                        // Long press recognized — lift the block
                        withAnimation(AtelierSpring.light) {
                            isLifted = true
                            liftRotation = Double.random(in: -1.2...1.2)
                        }
                        AtelierHaptics.shared.weight()
                    case .second(true, let drag):
                        if let drag {
                            dragOffset = drag.translation
                        }
                    default:
                        break
                    }
                }
                .onEnded { value in
                    // Drop with spring settle
                    let finalX = block.positionX + Double(dragOffset.width)
                    let finalY = block.positionY + Double(dragOffset.height)
                    onMove?(CGPoint(x: finalX, y: finalY))

                    withAnimation(AtelierSpring.heavy) {
                        isLifted = false
                        dragOffset = .zero
                    }
                    AtelierHaptics.shared.settle()
                }
        )
    }
}
