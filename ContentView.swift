import SwiftUI
import UserNotifications


final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    

    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notifications when the app is in the foreground
        completionHandler([.alert, .sound])
    }
    
    @objc private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        print("Notification was tapped")
    }
}

extension NotificationManager {
}

struct ContentView: View {
    @State private var notificationInterval: Double = 5
    @State private var notificationTitle: String = "Custom Notification"
    @State private var notificationMessage: String = "It's time to check the app!"
    @State private var isNotificationScheduled: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Settings")) {
                    TextField("Notification title", text: $notificationTitle)
                    
                    TextField("Notification message", text: $notificationMessage)
                    
                    Stepper(value: $notificationInterval, in: 5...3600, step: 5) {
                        Text("Interval: \(Int(notificationInterval)) seconds")
                    }
                }
                
                Section {
                    Button(action: {
                        if isNotificationScheduled {
                            cancelNotification()
                        } else {
                            scheduleNotification()
                        }
                    }) {
                        Text(isNotificationScheduled ? "Cancel Notification" : "Schedule Notification")
                    }
                }
            }
            .navigationTitle("Notification Demo")
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationMessage
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled with interval: \(notificationInterval) seconds")
                isNotificationScheduled = true
                startTimer()
            }
        }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["customNotification"])
        isNotificationScheduled = false
        timer?.invalidate()
    }
    
    func startTimer() {
        timer?.invalidate() /
        timer = Timer.scheduledTimer(withTimeInterval: notificationInterval, repeats: false) { _ in
            scheduleNotification()
        }
    }
}
