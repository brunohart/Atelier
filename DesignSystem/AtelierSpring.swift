import SwiftUI

enum AtelierSpring {
    // Primary — the signature interaction spring. Visible overshoot, snappy.
    // Page turns, card selection, shelf transitions.
    static let primary = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)

    // Heavy — drag release, shelf card landing. Slower, deeper overshoot.
    static let heavy = Animation.spring(response: 0.6, dampingFraction: 0.65, blendDuration: 0)

    // Light — micro-interactions, button presses. Quick and precise.
    static let light = Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)

    // Page — horizontal page turn. The signature gesture of the app.
    static let page = Animation.interpolatingSpring(stiffness: 180, damping: 22)

    // Reveal — splash and entrance animations. Slow, deliberate, earned.
    static let reveal = Animation.spring(response: 1.0, dampingFraction: 0.8, blendDuration: 0)

    // Settle — the final resting motion. Like an object finding its place.
    static let settle = Animation.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0)

    // Shelf zoom — transition between canvas and shelf view.
    static let shelfZoom = Animation.spring(response: 0.55, dampingFraction: 0.75, blendDuration: 0)
}
