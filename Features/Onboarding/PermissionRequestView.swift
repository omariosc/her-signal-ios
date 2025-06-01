import SwiftUI

struct PermissionRequestView: View {
    @StateObject private var permissionService = PermissionService()
    @State private var currentStep = 0
    @State private var isRequestingPermissions = false
    let onComplete: () -> Void
    
    private let permissions = [
        PermissionInfo(
            title: "Camera Access",
            description: "Record evidence from both front and back cameras during emergency situations",
            icon: "camera.fill",
            color: .purple
        ),
        PermissionInfo(
            title: "Microphone Access",
            description: "Capture audio for realistic emergency call simulation and evidence",
            icon: "mic.fill",
            color: .blue
        ),
        PermissionInfo(
            title: "Photo Library",
            description: "Automatically save emergency recordings to your Photos for easy access",
            icon: "photo.on.rectangle",
            color: .green
        ),
        PermissionInfo(
            title: "Location Services",
            description: "Share your location with emergency contacts and first responders",
            icon: "location.fill",
            color: .red
        ),
        PermissionInfo(
            title: "Notifications",
            description: "Receive important safety alerts and emergency contact notifications",
            icon: "bell.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .symbolEffect(.pulse)
                
                Text("Setup Permissions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("HerSignal needs these permissions to protect you effectively")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal)
            
            Spacer()
            
            // Permission Cards
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(permissions.enumerated()), id: \.offset) { index, permission in
                        PermissionCard(
                            permission: permission,
                            isActive: index <= currentStep,
                            isCompleted: getPermissionStatus(for: index) == .granted
                        )
                        .scaleEffect(index == currentStep ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                if currentStep < permissions.count {
                    Button(action: requestCurrentPermission) {
                        HStack {
                            if isRequestingPermissions {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                            }
                            
                            Text(isRequestingPermissions ? "Requesting..." : "Grant Permission")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    }
                    .disabled(isRequestingPermissions)
                    
                    Button("Skip for Now") {
                        nextStep()
                    }
                    .foregroundColor(.secondary)
                } else {
                    Button(action: {
                        onComplete()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                            
                            Text("Continue to HerSignal")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.05), .pink.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            permissionService.checkAllPermissions()
        }
    }
    
    private func requestCurrentPermission() {
        isRequestingPermissions = true
        
        Task {
            switch currentStep {
            case 0:
                await permissionService.requestCameraPermission()
            case 1:
                await permissionService.requestMicrophonePermission()
            case 2:
                await permissionService.requestPhotoLibraryPermission()
            case 3:
                await permissionService.requestLocationPermission()
            case 4:
                await permissionService.requestNotificationPermission()
            default:
                break
            }
            
            await MainActor.run {
                isRequestingPermissions = false
                nextStep()
            }
        }
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentStep < permissions.count {
                currentStep += 1
            }
        }
    }
    
    private func getPermissionStatus(for index: Int) -> PermissionService.PermissionStatus {
        switch index {
        case 0: return permissionService.cameraPermission
        case 1: return permissionService.microphonePermission
        case 2: return permissionService.photoLibraryPermission
        case 3: return permissionService.locationPermission
        case 4: return permissionService.notificationPermission
        default: return .notDetermined
        }
    }
}

struct PermissionCard: View {
    let permission: PermissionInfo
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(permission.color.opacity(isActive ? 0.2 : 0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isCompleted ? "checkmark" : permission.icon)
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : (isActive ? permission.color : .secondary))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(permission.title)
                    .font(.headline)
                    .foregroundColor(isActive ? .primary : .secondary)
                
                Text(permission.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: isActive ? permission.color.opacity(0.3) : .black.opacity(0.1),
                    radius: isActive ? 8 : 4,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isCompleted ? .green : (isActive ? permission.color : .clear),
                    lineWidth: isActive || isCompleted ? 2 : 0
                )
        )
    }
}

struct PermissionInfo {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

#Preview {
    PermissionRequestView {
        print("Permissions setup complete")
    }
}