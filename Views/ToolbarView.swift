import SwiftUI

// ToolbarView is no longer used — replaced by floating add button in CanvasView.
// Keeping file to avoid breaking any existing references during transition.
struct ToolbarView: View {
    var viewModel: CanvasViewModel

    var body: some View {
        EmptyView()
    }
}
