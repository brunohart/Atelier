import SwiftUI

enum AtelierColors {
    // Primary palette — warm parchment world
    static let parchment = Color(red: 240/255, green: 237/255, blue: 230/255)
    static let ink = Color(red: 26/255, green: 26/255, blue: 26/255)
    static let burntOrange = Color(red: 212/255, green: 98/255, blue: 43/255)

    // Supporting tones
    static let navy = Color(red: 27/255, green: 45/255, blue: 79/255)
    static let warmGray = Color(red: 138/255, green: 133/255, blue: 120/255)
    static let cream = Color(red: 245/255, green: 240/255, blue: 225/255)
    static let deepParchment = Color(red: 225/255, green: 220/255, blue: 210/255)

    // Functional
    static let inkLight = Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.4)
    static let inkFaint = Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.12)
    static let cardShadow = Color.black.opacity(0.08)

    // The rule: burntOrange is the wax seal.
    // Used ONLY for: active states, waveform playhead, splash accent, creation action.
    // Never for backgrounds. Never for large surfaces.
}
