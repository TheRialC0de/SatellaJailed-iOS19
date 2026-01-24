import SwiftUI

@main
struct AppSelectorApp: App {
    @StateObject private var viewModel = AppListViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
