import UserNotifications
import UIKit

class NotificationService: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestNotificationPermission() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge, .criticalAlert]
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = granted
                self?.checkAuthorizationStatus()
            }
        } catch {
            print("Notification permission request failed: \(error)")
        }
    }
    
    func scheduleEmergencyNotification(to contacts: [EmergencyContact], location: String?) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "HerSignal Emergency Alert"
        content.body = location != nil ? 
            "Emergency activated at: \(location!)" : 
            "Emergency activated - location unavailable"
        content.sound = .defaultCritical
        content.categoryIdentifier = "EMERGENCY_ALERT"
        
        // Schedule immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "emergency_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule emergency notification: \(error)")
            }
        }
    }
    
    func scheduleCheckInNotification(delay: TimeInterval = 3600) { // 1 hour default
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Safety Check-In"
        content.body = "Are you still safe? Tap to confirm you're okay."
        content.sound = .default
        content.categoryIdentifier = "SAFETY_CHECKIN"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: "checkin_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule check-in notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func cancelNotifications(withIdentifierPrefix prefix: String) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func setupNotificationCategories() {
        // Emergency alert actions
        let confirmSafeAction = UNNotificationAction(
            identifier: "CONFIRM_SAFE",
            title: "I'm Safe",
            options: [.foreground]
        )
        
        let needHelpAction = UNNotificationAction(
            identifier: "NEED_HELP",
            title: "Send Help",
            options: [.foreground]
        )
        
        let emergencyCategory = UNNotificationCategory(
            identifier: "EMERGENCY_ALERT",
            actions: [confirmSafeAction, needHelpAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Emergency Alert",
            options: .customDismissAction
        )
        
        // Check-in actions
        let safeAction = UNNotificationAction(
            identifier: "SAFE_CHECKIN",
            title: "I'm Safe",
            options: []
        )
        
        let checkinCategory = UNNotificationCategory(
            identifier: "SAFETY_CHECKIN",
            actions: [safeAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Safety Check-In",
            options: .customDismissAction
        )
        
        notificationCenter.setNotificationCategories([emergencyCategory, checkinCategory])
    }
}