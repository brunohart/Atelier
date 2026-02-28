import SwiftUI
import SwiftData

enum AppPhase: Equatable {
    case splash
    case canvas(index: Int)
    case shelf
}

struct NavigationContainer: View {
    @State private var phase: AppPhase = .splash
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var shelfScale: CGFloat = 1.0
    @State private var showPageCurlHint = false
    @State private var hasShownCurlHint = false

    @Namespace private var shelfTransition

    @Query(sort: \AtelierCanvas.sortOrder) private var canvases: [AtelierCanvas]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashView {
                    ensureDemoContent()
                    withAnimation(AtelierSpring.primary) {
                        phase = .canvas(index: 0)
                        currentIndex = 0
                    }
                }
                .transition(.opacity)

            case .canvas:
                canvasPageView
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.0).combined(with: .opacity),
                        removal: .scale(scale: 0.85).combined(with: .opacity)
                    ))

            case .shelf:
                ShelfView(namespace: shelfTransition) { index in
                    withAnimation(AtelierSpring.shelfZoom) {
                        currentIndex = index
                        phase = .canvas(index: index)
                    }
                    AtelierHaptics.shared.weight()
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 1.1).combined(with: .opacity),
                    removal: .scale(scale: 1.0).combined(with: .opacity)
                ))
            }
        }
        .animation(AtelierSpring.primary, value: phase)
    }

    // MARK: - Canvas Page View (horizontal paging)

    @ViewBuilder
    private var canvasPageView: some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width

            ZStack {
                // Canvas pages with edge peek
                HStack(spacing: 0) {
                    ForEach(Array(canvases.enumerated()), id: \.element.id) { index, canvas in
                        CanvasView(canvas: canvas)
                            .frame(width: pageWidth)
                    }
                }
                .offset(x: -CGFloat(currentIndex) * pageWidth + dragOffset)

                // Edge peek shadows — show depth at screen edges
                edgePeekOverlay(pageWidth: pageWidth)

                // Top bar: canvas title + navigation
                VStack {
                    canvasTitleBar
                        .padding(.top, 8)
                    Spacer()
                }

                // Page indicator + shelf hint at bottom
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        pageIndicator
                        Spacer()
                        shelfButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                // Page curl hint animation
                if showPageCurlHint {
                    pageCurlHintView(pageWidth: pageWidth)
                }
            }
            .clipped()
            .gesture(pageDragGesture(pageWidth: pageWidth))
            .simultaneousGesture(pinchToShelfGesture)
            .scaleEffect(min(shelfScale, 1.0))
            .task {
                await showCurlHintIfNeeded()
            }
        }
    }

    // MARK: - Canvas Title Bar

    private var canvasTitleBar: some View {
        HStack {
            // Left arrow hint
            if currentIndex > 0 {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AtelierColors.warmGray.opacity(0.5))
            }

            Spacer()

            // Canvas title
            if currentIndex < canvases.count {
                Text(canvases[currentIndex].title.uppercased())
                    .font(AtelierType.mono)
                    .foregroundStyle(AtelierColors.warmGray)
                    .tracking(2)
            }

            Spacer()

            // Right arrow hint
            if currentIndex < canvases.count - 1 {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AtelierColors.warmGray.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    // MARK: - Edge Peek Overlay

    private func edgePeekOverlay(pageWidth: CGFloat) -> some View {
        HStack {
            // Left edge shadow — shows there's a canvas to the left
            if currentIndex > 0 {
                LinearGradient(
                    colors: [AtelierColors.ink.opacity(0.08), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 20)
                .allowsHitTesting(false)
            }

            Spacer()

            // Right edge shadow — shows there's a canvas to the right
            if currentIndex < canvases.count - 1 {
                LinearGradient(
                    colors: [.clear, AtelierColors.ink.opacity(0.08)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 20)
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Page Curl Hint

    private func pageCurlHintView(pageWidth: CGFloat) -> some View {
        // A subtle visual hint at the right edge that peels back
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 2)
                .fill(AtelierColors.ink.opacity(0.06))
                .frame(width: 24, height: 120)
                .offset(x: showPageCurlHint ? -4 : 20)
                .animation(
                    AtelierSpring.primary.repeatCount(1, autoreverses: true),
                    value: showPageCurlHint
                )
        }
        .allowsHitTesting(false)
    }

    private func showCurlHintIfNeeded() async {
        guard !hasShownCurlHint, canvases.count > 1 else { return }
        hasShownCurlHint = true

        // Wait for entry animation to finish
        try? await Task.sleep(for: .milliseconds(1500))

        withAnimation(AtelierSpring.primary) {
            showPageCurlHint = true
        }

        try? await Task.sleep(for: .milliseconds(1200))

        withAnimation(AtelierSpring.settle) {
            showPageCurlHint = false
        }
    }

    // MARK: - Gestures

    private func pageDragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global)
            .onChanged { value in
                // Only respond to predominantly horizontal drags
                let horizontal = abs(value.translation.width)
                let vertical = abs(value.translation.height)
                guard horizontal > vertical * 0.8 else { return }

                isDragging = true
                let translation = value.translation.width

                // Resistance at edges (rubber-band)
                if (currentIndex == 0 && translation > 0) ||
                   (currentIndex == canvases.count - 1 && translation < 0) {
                    dragOffset = translation * 0.3
                } else {
                    dragOffset = translation
                }
            }
            .onEnded { value in
                isDragging = false
                let velocity = value.predictedEndTranslation.width
                let threshold: CGFloat = pageWidth * 0.3

                withAnimation(AtelierSpring.page) {
                    if (dragOffset + velocity) < -threshold && currentIndex < canvases.count - 1 {
                        currentIndex += 1
                        AtelierHaptics.shared.friction()
                    } else if (dragOffset + velocity) > threshold && currentIndex > 0 {
                        currentIndex -= 1
                        AtelierHaptics.shared.friction()
                    } else if abs(dragOffset) > 10 {
                        AtelierHaptics.shared.resistance()
                    }
                    dragOffset = 0
                }

                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(400))
                    AtelierHaptics.shared.settle()
                }
            }
    }

    private var pinchToShelfGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                shelfScale = value.magnification
            }
            .onEnded { value in
                if value.magnification < 0.7 {
                    withAnimation(AtelierSpring.shelfZoom) {
                        phase = .shelf
                        shelfScale = 1.0
                    }
                    AtelierHaptics.shared.weight()
                } else {
                    withAnimation(AtelierSpring.settle) {
                        shelfScale = 1.0
                    }
                }
            }
    }

    // MARK: - Shelf Button

    private var shelfButton: some View {
        Button {
            withAnimation(AtelierSpring.shelfZoom) {
                phase = .shelf
            }
            AtelierHaptics.shared.weight()
        } label: {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AtelierColors.warmGray)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AtelierColors.cream.opacity(0.9))
                        .shadow(color: AtelierColors.cardShadow, radius: 8, y: 2)
                )
        }
        .buttonStyle(SpringButtonStyle())
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<canvases.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? AtelierColors.ink : AtelierColors.ink.opacity(0.2))
                    .frame(width: index == currentIndex ? 7 : 5, height: index == currentIndex ? 7 : 5)
                    .animation(AtelierSpring.light, value: currentIndex)
            }
        }
    }

    // MARK: - Demo Content

    private func ensureDemoContent() {
        guard canvases.isEmpty else { return }
        DemoContent.createAllCanvases(in: modelContext)
    }
}
