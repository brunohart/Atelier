import SwiftUI
import SwiftData

@main
struct AtelierApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationContainer()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [AtelierCanvas.self, TextBlock.self])
    }
}
