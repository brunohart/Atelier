import SwiftUI

struct SpringButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            AtelierHaptics.shared.tap()
            action()
        }) {
            label()
        }
        .buttonStyle(SpringButtonStyle())
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(AtelierSpring.light, value: configuration.isPressed)
    }
}
