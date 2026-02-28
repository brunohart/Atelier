import SwiftUI

// The wax seal. Used sparingly — a mark of intention.

struct AccentLine: View {
    var width: CGFloat = 40
    var height: CGFloat = 2

    var body: some View {
        Rectangle()
            .fill(AtelierColors.burntOrange)
            .frame(width: width, height: height)
    }
}

struct AccentDot: View {
    var size: CGFloat = 6

    var body: some View {
        Circle()
            .fill(AtelierColors.burntOrange)
            .frame(width: size, height: size)
    }
}

struct StampLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AtelierType.mono)
            .foregroundStyle(AtelierColors.warmGray)
            .tracking(1.5)
            .textCase(.uppercase)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(AtelierColors.warmGray.opacity(0.4), lineWidth: 0.5)
            )
            .rotationEffect(.degrees(-0.8))
    }
}
