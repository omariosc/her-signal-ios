import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingEmergencyCall = false
    @State private var showingOnboarding = false
    
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
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                            .symbolEffect(.pulse)
                        
                        Text("HerSignal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Your AI Safety Companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Emergency activation button
                    Button(action: {
                        triggerEmergencyCall()
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
                            action: { /* Navigate to settings */ }
                        )
                        
                        QuickActionButton(
                            icon: "person.2.fill",
                            title: "Contacts",
                            action: { /* Navigate to emergency contacts */ }
                        )
                        
                        QuickActionButton(
                            icon: "questionmark.circle.fill",
                            title: "Help",
                            action: { /* Show help/tutorial */ }
                        )
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingEmergencyCall) {
            EmergencyCallView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .onAppear {
            if !appState.isOnboardingComplete {
                showingOnboarding = true
            }
        }
    }
    
    private func triggerEmergencyCall() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
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