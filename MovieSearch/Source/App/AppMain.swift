import Logging
import Pulse
import SwiftUI
import UIKit

@main
struct AppMain: App {
    init() {
        setupNavbarAppearance()
        LoggingSystem.bootstrap(PersistentLogHandler.init)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func setupNavbarAppearance() {
        let appearance = UINavigationBarAppearance()

        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "movie-green")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor.white

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
    }
}
