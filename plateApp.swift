import SwiftUI

@main
struct plateApp: App {
    @StateObject private var store = MealStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
