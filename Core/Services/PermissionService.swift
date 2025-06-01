import Foundation
import AVFoundation
import Photos
import CoreLocation
import UserNotifications

class PermissionService: ObservableObject {
    @Published var cameraPermission: PermissionStatus = .notDetermined
    @Published var microphonePermission: PermissionStatus = .notDetermined
    @Published var photoLibraryPermission: PermissionStatus = .notDetermined
    @Published var locationPermission: PermissionStatus = .notDetermined
    @Published var notificationPermission: PermissionStatus = .notDetermined
    
    @Published var allPermissionsGranted = false
    
    private let locationManager = CLLocationManager()
    
    enum PermissionStatus {
        case notDetermined
        case granted
        case denied
        case restricted
    }
    
    init() {
        checkAllPermissions()
    }
    
    func requestAllPermissions() async {
        await requestCameraPermission()
        await requestMicrophonePermission()
        await requestPhotoLibraryPermission()
        await requestLocationPermission()
        await requestNotificationPermission()
        
        await MainActor.run {
            updateAllPermissionsStatus()
            savePermissionPreferences()
        }
    }
    
    func checkAllPermissions() {
        checkCameraPermission()
        checkMicrophonePermission()
        checkPhotoLibraryPermission()
        checkLocationPermission()
        checkNotificationPermission()
        updateAllPermissionsStatus()
    }
    
    // MARK: - Camera Permission
    
    @MainActor
    func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraPermission = granted ? .granted : .denied
        case .authorized:
            cameraPermission = .granted
        case .denied:
            cameraPermission = .denied
        case .restricted:
            cameraPermission = .restricted
        @unknown default:
            cameraPermission = .denied
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                self.cameraPermission = .notDetermined
            case .authorized:
                self.cameraPermission = .granted
            case .denied:
                self.cameraPermission = .denied
            case .restricted:
                self.cameraPermission = .restricted
            @unknown default:
                self.cameraPermission = .denied
            }
        }
    }
    
    // MARK: - Microphone Permission
    
    @MainActor
    func requestMicrophonePermission() async {
        let status = AVAudioSession.sharedInstance().recordPermission
        
        switch status {
        case .undetermined:
            let granted = await AVAudioSession.sharedInstance().requestRecordPermission()
            microphonePermission = granted ? .granted : .denied
        case .granted:
            microphonePermission = .granted
        case .denied:
            microphonePermission = .denied
        @unknown default:
            microphonePermission = .denied
        }
    }
    
    private func checkMicrophonePermission() {
        let status = AVAudioSession.sharedInstance().recordPermission
        
        DispatchQueue.main.async {
            switch status {
            case .undetermined:
                self.microphonePermission = .notDetermined
            case .granted:
                self.microphonePermission = .granted
            case .denied:
                self.microphonePermission = .denied
            @unknown default:
                self.microphonePermission = .denied
            }
        }
    }
    
    // MARK: - Photo Library Permission
    
    @MainActor
    func requestPhotoLibraryPermission() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            photoLibraryPermission = (newStatus == .authorized) ? .granted : .denied
        case .authorized:
            photoLibraryPermission = .granted
        case .denied:
            photoLibraryPermission = .denied
        case .restricted:
            photoLibraryPermission = .restricted
        case .limited:
            photoLibraryPermission = .granted // Limited access is sufficient for adding photos
        @unknown default:
            photoLibraryPermission = .denied
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                self.photoLibraryPermission = .notDetermined
            case .authorized, .limited:
                self.photoLibraryPermission = .granted
            case .denied:
                self.photoLibraryPermission = .denied
            case .restricted:
                self.photoLibraryPermission = .restricted
            @unknown default:
                self.photoLibraryPermission = .denied
            }
        }
    }
    
    // MARK: - Location Permission
    
    @MainActor
    func requestLocationPermission() async {
        guard CLLocationManager.locationServicesEnabled() else {
            locationPermission = .denied
            return
        }
        
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Note: The result will be handled in the delegate
            locationPermission = .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermission = .granted
        case .denied:
            locationPermission = .denied
        case .restricted:
            locationPermission = .restricted
        @unknown default:
            locationPermission = .denied
        }
    }
    
    private func checkLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            DispatchQueue.main.async {
                self.locationPermission = .denied
            }
            return
        }
        
        let status = locationManager.authorizationStatus
        
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                self.locationPermission = .notDetermined
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationPermission = .granted
            case .denied:
                self.locationPermission = .denied
            case .restricted:
                self.locationPermission = .restricted
            @unknown default:
                self.locationPermission = .denied
            }
        }
    }
    
    // MARK: - Notification Permission
    
    @MainActor
    func requestNotificationPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                notificationPermission = granted ? .granted : .denied
            } catch {
                notificationPermission = .denied
            }
        case .authorized, .provisional, .ephemeral:
            notificationPermission = .granted
        case .denied:
            notificationPermission = .denied
        @unknown default:
            notificationPermission = .denied
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.notificationPermission = .notDetermined
                case .authorized, .provisional, .ephemeral:
                    self.notificationPermission = .granted
                case .denied:
                    self.notificationPermission = .denied
                @unknown default:
                    self.notificationPermission = .denied
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateAllPermissionsStatus() {
        allPermissionsGranted = cameraPermission == .granted &&
                               microphonePermission == .granted &&
                               photoLibraryPermission == .granted &&
                               locationPermission == .granted &&
                               notificationPermission == .granted
    }
    
    private func savePermissionPreferences() {
        let preferences = [
            "camera": cameraPermission == .granted,
            "microphone": microphonePermission == .granted,
            "photoLibrary": photoLibraryPermission == .granted,
            "location": locationPermission == .granted,
            "notifications": notificationPermission == .granted
        ]
        
        UserDefaults.standard.set(preferences, forKey: "HerSignal_Permissions")
    }
    
    func loadPermissionPreferences() -> [String: Bool] {
        return UserDefaults.standard.dictionary(forKey: "HerSignal_Permissions") as? [String: Bool] ?? [:]
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func getPermissionStatusText(_ status: PermissionStatus) -> String {
        switch status {
        case .notDetermined:
            return "Not Requested"
        case .granted:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        }
    }
    
    func getPermissionColor(_ status: PermissionStatus) -> String {
        switch status {
        case .granted:
            return "green"
        case .denied, .restricted:
            return "red"
        case .notDetermined:
            return "orange"
        }
    }
}