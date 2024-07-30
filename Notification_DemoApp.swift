import SwiftUI


@main
struct NotificationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UNUserNotificationCenter.current().delegate = NotificationManager.shared
                }
        }
    }
}
