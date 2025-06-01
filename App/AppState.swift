import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isOnboardingComplete = false
    @Published var hasLocationPermission = false
    @Published var hasMicrophonePermission = false
    @Published var hasNotificationPermission = false
    @Published var hasCameraPermission = false
    @Published var isEmergencyMode = false
    
    private var permissionService = PermissionService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserSettings()
        setupSubscriptions()
    }
    
    func requestInitialPermissions() {
        // Check if onboarding is complete
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
        
        // Request permissions if onboarding is complete
        if isOnboardingComplete {
            checkPermissionStatus()
        }
    }
    
    private func loadUserSettings() {
        // Load user preferences from UserDefaults
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
    }
    
    private func setupSubscriptions() {
        // Monitor permission changes
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkPermissionStatus()
            }
            .store(in: &cancellables)
    }
    
    private func checkPermissionStatus() {
        // Check current permission status using PermissionService
        permissionService.checkAllPermissions()
        
        hasLocationPermission = permissionService.locationPermission == .granted
        hasMicrophonePermission = permissionService.microphonePermission == .granted
        hasNotificationPermission = permissionService.notificationPermission == .granted
        hasCameraPermission = permissionService.cameraPermission == .granted
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
    }
    
    func activateEmergencyMode() {
        isEmergencyMode = true
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func deactivateEmergencyMode() {
        isEmergencyMode = false
    }
    
    func requestAllPermissions() async {
        await permissionService.requestAllPermissions()
        checkPermissionStatus()
    }
    
    var allPermissionsGranted: Bool {
        return hasCameraPermission && hasMicrophonePermission && hasLocationPermission && hasNotificationPermission
    }
}