import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var permissionService = PermissionService()
    @State private var showingEmergencyCall = false
    @State private var showingOnboarding = false
    @State private var showingPermissions = false
    @State private var showingSettings = false
    @State private var showingContacts = false
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main interface
                VStack(spacing: 30) {
                    // App logo and title
                    VStack(spacing: 16) {
                        // Use custom app logo
                        Image("HerSignal-Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Text("HerSignal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Your AI Safety Companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Permission status indicator
                        if !permissionService.allPermissionsGranted {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                
                                Text("Setup Required")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Capsule())
                            .onTapGesture {
                                showingPermissions = true
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Emergency activation button
                    Button(action: {
                        if permissionService.cameraPermission == .granted && permissionService.microphonePermission == .granted {
                            triggerEmergencyCall()
                        } else {
                            showingPermissions = true
                        }
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            
                            Text("Start Safety Call")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(width: 200, height: 200)
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                        .scaleEffect(showingEmergencyCall ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: showingEmergencyCall)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Quick access buttons
                    HStack(spacing: 20) {
                        QuickActionButton(
                            icon: "gearshape.fill",
                            title: "Settings",
                            action: { 
                                showingSettings = true
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        )
                        
                        QuickActionButton(
                            icon: "person.2.fill",
                            title: "Contacts",
                            action: { 
                                showingContacts = true
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        )
                        
                        QuickActionButton(
                            icon: "questionmark.circle.fill",
                            title: "Help",
                            action: { 
                                showingHelp = true
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        )
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingEmergencyCall) {
            FaceTimeCallView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .fullScreenCover(isPresented: $showingPermissions) {
            PermissionRequestView {
                showingPermissions = false
                permissionService.checkAllPermissions()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(permissionService)
        }
        .sheet(isPresented: $showingContacts) {
            EmergencyContactsView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .onAppear {
            permissionService.checkAllPermissions()
            
            if !appState.isOnboardingComplete {
                showingOnboarding = true
            } else if !permissionService.allPermissionsGranted {
                // Show permissions if not all granted
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingPermissions = true
                }
            }
        }
        .onChange(of: appState.isOnboardingComplete) { completed in
            if completed && !permissionService.allPermissionsGranted {
                showingPermissions = true
            }
        }
    }
    
    private func triggerEmergencyCall() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Trigger notification feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
        
        appState.activateEmergencyMode()
        showingEmergencyCall = true
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}