import SwiftUI

@main
struct HerSignalApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    setupAppearance()
                    requestPermissions()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure app-wide appearance
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.systemPurple
        ]
        
        // Configure tab bar appearance
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
    }
    
    private func requestPermissions() {
        // Request initial permissions on app launch
        appState.requestInitialPermissions()
    }
}