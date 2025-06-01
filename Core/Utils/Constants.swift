import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - App Information
    struct App {
        static let name = "HerSignal"
        static let bundleIdentifier = "com.hersignal.app"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        static let displayVersion = "\(version) (\(build))"
    }
    
    // MARK: - API Configuration
    struct API {
        #if DEBUG
        static let baseURL = "https://api-dev.hersignal.com"
        #else
        static let baseURL = "https://api.hersignal.com"
        #endif
        
        static let timeout: TimeInterval = 30.0
        static let retryAttempts = 3
    }
    
    // MARK: - Emergency Settings
    struct Emergency {
        static let defaultAutoAnswerDelay: TimeInterval = 3.0
        static let maxCallDuration: TimeInterval = 3600 // 1 hour
        static let defaultCheckInInterval: TimeInterval = 3600 // 1 hour
        static let maxEmergencyContacts = 5
        static let minPhoneNumberLength = 10
    }
    
    // MARK: - Voice Settings
    struct Voice {
        static let defaultSpeechRate: Float = 0.5
        static let defaultPitchMultiplier: Float = 1.0
        static let defaultVolume: Float = 0.8
        static let messagePauseDuration: TimeInterval = 0.3
        static let conversationDelay = 8.0...15.0 // Random range
    }
    
    // MARK: - Location Settings
    struct Location {
        static let accuracyThreshold: Double = 100 // meters
        static let updateInterval: TimeInterval = 10 // seconds
        static let maxLocationAge: TimeInterval = 300 // 5 minutes
        static let geocodingTimeout: TimeInterval = 10
    }
    
    // MARK: - UI Constants
    struct UI {
        static let animationDuration: TimeInterval = 0.3
        static let hapticFeedbackIntensity: Float = 0.8
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 4
        static let buttonHeight: CGFloat = 50
        
        struct Colors {
            static let primary = Color.purple
            static let secondary = Color.pink
            static let accent = Color.blue
            static let success = Color.green
            static let warning = Color.orange
            static let error = Color.red
            
            static let backgroundPrimary = Color(.systemBackground)
            static let backgroundSecondary = Color(.secondarySystemBackground)
            static let textPrimary = Color(.label)
            static let textSecondary = Color(.secondaryLabel)
        }
        
        struct Gradients {
            static let primary = LinearGradient(
                colors: [Colors.primary, Colors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            static let emergency = LinearGradient(
                colors: [Colors.error, Colors.warning],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            static let success = LinearGradient(
                colors: [Colors.success, Colors.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let onboardingComplete = "onboarding_complete"
        static let firstLaunch = "first_launch"
        static let lastVersionLaunched = "last_version_launched"
        static let preferredVoice = "preferred_voice"
        static let defaultScenario = "default_scenario"
        static let autoAnswerDelay = "auto_answer_delay"
        static let locationSharingEnabled = "location_sharing_enabled"
        static let notificationsEnabled = "notifications_enabled"
        static let hasRequestedPermissions = "has_requested_permissions"
        static let lastEmergencyActivation = "last_emergency_activation"
        static let totalEmergencyActivations = "total_emergency_activations"
    }
    
    // MARK: - Keychain Keys
    struct KeychainKeys {
        static let emergencyContacts = "emergency_contacts"
        static let userPreferences = "user_preferences"
        static let callHistory = "call_history"
        static let locationHistory = "location_history"
        static let deviceIdentifier = "device_identifier"
    }
    
    // MARK: - Notification Identifiers
    struct NotificationIdentifiers {
        static let emergencyAlert = "emergency_alert"
        static let safetyCheckin = "safety_checkin"
        static let locationUpdate = "location_update"
        static let appReminder = "app_reminder"
    }
    
    // MARK: - URL Schemes
    struct URLSchemes {
        static let emergency = "hersignal://emergency"
        static let settings = "hersignal://settings"
        static let contacts = "hersignal://contacts"
        static let help = "hersignal://help"
    }
    
    // MARK: - Analytics Events
    struct AnalyticsEvents {
        static let appLaunched = "app_launched"
        static let onboardingCompleted = "onboarding_completed"
        static let emergencyActivated = "emergency_activated"
        static let emergencyEnded = "emergency_ended"
        static let contactAdded = "contact_added"
        static let settingsChanged = "settings_changed"
        static let permissionGranted = "permission_granted"
        static let permissionDenied = "permission_denied"
    }
    
    // MARK: - File Names
    struct FileNames {
        static let emergencyContacts = "emergency_contacts.json"
        static let userPreferences = "user_preferences.json"
        static let callHistory = "call_history.json"
        static let logs = "app_logs.txt"
    }
    
    // MARK: - External URLs
    struct ExternalURLs {
        static let website = "https://her-signal.org"
        static let privacyPolicy = "https://her-signal.org/privacy"
        static let termsOfService = "https://her-signal.org/terms"
        static let support = "https://her-signal.org/support"
        static let feedback = "mailto:feedback@her-signal.org"
        static let emergency911 = "tel://911"
        static let emergency999 = "tel://999"
        static let emergency112 = "tel://112"
    }
    
    // MARK: - Error Codes
    struct ErrorCodes {
        static let locationUnavailable = 1001
        static let microphoneUnavailable = 1002
        static let contactsUnavailable = 1003
        static let notificationUnavailable = 1004
        static let networkUnavailable = 1005
        static let storageFailure = 1006
        static let encryptionFailure = 1007
        static let voiceSynthesisFailure = 1008
    }
    
    // MARK: - Feature Flags
    struct FeatureFlags {
        #if DEBUG
        static let enableDebugMode = true
        static let enableTestContacts = true
        static let enableMockLocation = true
        #else
        static let enableDebugMode = false
        static let enableTestContacts = false
        static let enableMockLocation = false
        #endif
        
        static let enableLocationSharing = true
        static let enableVoicePersonalization = true
        static let enableAdvancedSettings = false
        static let enableAnalytics = false // Privacy-first approach
    }
}