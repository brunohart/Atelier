import SwiftUI
import PencilKit

struct CanvasView: View {
    let canvas: AtelierCanvas
    @State private var viewModel: CanvasViewModel
    @State private var sketchData: Data?

    // Entry animation
    @State private var elementsRevealed = false
    @State private var titleRevealed = false
    @State private var bodyRevealed = false
    @State private var waveformRevealed = false
    @State private var sketchRevealed = false

    init(canvas: AtelierCanvas) {
        self.canvas = canvas
        self._viewModel = State(initialValue: CanvasViewModel(canvas: canvas))
        self._sketchData = State(initialValue: canvas.sketchData)
    }

    var body: some View {
        ZStack {
            ParchmentBackground()

            // Freeform canvas surface
            canvasSurface
                .offset(x: viewModel.canvasOffset.width + viewModel.canvasDragOffset.width,
                        y: viewModel.canvasOffset.height + viewModel.canvasDragOffset.height)

            // Grain overlay
            GrainOverlay()
                .allowsHitTesting(false)

            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 32)
                }
            }

            // Add menu popup
            if viewModel.isShowingAddMenu {
                addMenuOverlay
            }
        }
        .task {
            await playEntryAnimation()
        }
    }

    // MARK: - Freeform Canvas Surface

    @ViewBuilder
    private var canvasSurface: some View {
        ZStack(alignment: .topLeading) {
            // Sketch layer — always behind, always accessible with Pencil
            if viewModel.hasSketch || sketchData != nil {
                SketchLayerView(drawingData: $sketchData)
                    .opacity(sketchRevealed ? 0.7 : 0)
                    .animation(AtelierSpring.reveal, value: sketchRevealed)
                    .onChange(of: sketchData) { _, newValue in
                        canvas.sketchData = newValue
                    }
            }

            // Waveform — positioned as a draggable card
            if let amplitudes = canvas.waveformAmplitudes {
                AudioWaveformView(amplitudes: amplitudes)
                    .frame(width: 340)
                    .offset(x: waveformX, y: waveformY)
                    .opacity(waveformRevealed ? 1 : 0)
                    .offset(x: waveformRevealed ? 0 : 60)
                    .animation(AtelierSpring.primary, value: waveformRevealed)
            }

            // Text blocks — freeform positioned, draggable
            ForEach(viewModel.sortedTextBlocks, id: \.id) { block in
                let blockIndex = viewModel.sortedTextBlocks.firstIndex(where: { $0.id == block.id }) ?? 0
                let isTitle = block.isTitle

                TextBlockView(
                    block: block,
                    onUpdate: { newContent in
                        viewModel.updateTextBlock(block, content: newContent)
                    },
                    onMove: { newPosition in
                        viewModel.moveBlock(block, to: newPosition)
                    },
                    isDragging: viewModel.draggedBlockID == block.id
                )
                .position(x: block.positionX + block.width / 2,
                          y: block.positionY)
                .opacity(blockOpacity(index: blockIndex, isTitle: isTitle))
                .offset(y: blockEntryOffset(index: blockIndex, isTitle: isTitle))
                .animation(
                    AtelierSpring.primary.delay(Double(blockIndex) * 0.06),
                    value: elementsRevealed
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Entry Animation Helpers

    private func blockOpacity(index: Int, isTitle: Bool) -> Double {
        if isTitle {
            return titleRevealed ? 1 : 0
        }
        return bodyRevealed ? 1 : 0
    }

    private func blockEntryOffset(index: Int, isTitle: Bool) -> CGFloat {
        if isTitle {
            return titleRevealed ? 0 : 24
        }
        return bodyRevealed ? 0 : 16
    }

    // MARK: - Entry Animation Sequence

    private func playEntryAnimation() async {
        // Step 1: Title rises in (200ms delay)
        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(AtelierSpring.reveal) {
            titleRevealed = true
        }
        AtelierHaptics.shared.settle()

        // Step 2: Body text blocks stagger in (300ms later)
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(AtelierSpring.primary) {
            bodyRevealed = true
            elementsRevealed = true
        }

        // Step 3: Waveform slides in from right (200ms later)
        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(AtelierSpring.primary) {
            waveformRevealed = true
        }
        AtelierHaptics.shared.settle()

        // Step 4: Sketch fades in (200ms later)
        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(AtelierSpring.reveal) {
            sketchRevealed = true
        }
    }

    // MARK: - Waveform Position

    private var waveformX: CGFloat {
        // Position waveform below the text blocks, offset right
        let lastBlock = viewModel.sortedTextBlocks.last
        return CGFloat(lastBlock?.positionX ?? 40) + 20
    }

    private var waveformY: CGFloat {
        let lastBlock = viewModel.sortedTextBlocks.last
        return CGFloat(lastBlock?.positionY ?? 200) + 120
    }

    // MARK: - Floating Add Button

    private var addButton: some View {
        Button {
            withAnimation(AtelierSpring.light) {
                viewModel.isShowingAddMenu.toggle()
            }
            AtelierHaptics.shared.tap()
        } label: {
            Image(systemName: viewModel.isShowingAddMenu ? "xmark" : "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(AtelierColors.parchment)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AtelierColors.burntOrange)
                        .shadow(color: AtelierColors.burntOrange.opacity(0.3), radius: 12, y: 4)
                )
                .rotationEffect(.degrees(viewModel.isShowingAddMenu ? 90 : 0))
                .animation(AtelierSpring.light, value: viewModel.isShowingAddMenu)
        }
        .buttonStyle(SpringButtonStyle())
    }

    // MARK: - Add Menu Overlay

    private var addMenuOverlay: some View {
        ZStack {
            // Dismiss backdrop
            Color.black.opacity(0.01)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(AtelierSpring.light) {
                        viewModel.isShowingAddMenu = false
                    }
                }

            // Menu items
            VStack(spacing: 12) {
                addMenuItem(icon: "text.alignleft", label: "TEXT") {
                    viewModel.addTextBlock(content: "New note")
                    viewModel.isShowingAddMenu = false
                    AtelierHaptics.shared.tap()
                }

                addMenuItem(icon: "pencil.tip", label: "SKETCH") {
                    // Initialize sketch layer if needed
                    if sketchData == nil {
                        sketchData = PKDrawing().dataRepresentation()
                        canvas.sketchData = sketchData
                    }
                    sketchRevealed = true
                    viewModel.isShowingAddMenu = false
                    AtelierHaptics.shared.tap()
                }
            }
            .padding(.bottom, 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, 30)
        }
    }

    private func addMenuItem(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(label)
                    .font(AtelierType.mono)
                    .foregroundStyle(AtelierColors.ink)
                    .tracking(1.5)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AtelierColors.parchment)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(AtelierColors.ink.opacity(0.85))
                    )
            }
        }
        .buttonStyle(SpringButtonStyle())
        .transition(.scale(scale: 0.5).combined(with: .opacity))
    }
}
