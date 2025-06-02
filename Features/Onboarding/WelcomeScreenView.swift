import SwiftUI

struct WelcomeScreenView: View {
    @State private var showPhoneAnimation = false
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header with skip button
                HStack {
                    Spacer()
                    
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Phone mockup
                PhoneMockupView()
                    .scaleEffect(showPhoneAnimation ? 1.0 : 0.8)
                    .opacity(showPhoneAnimation ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 1.0).delay(0.3), value: showPhoneAnimation)
                
                Spacer()
                
                // Welcome content
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Welcome to")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(showPhoneAnimation ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.8).delay(1.3), value: showPhoneAnimation)
                        
                        Text("HerSignal")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(showPhoneAnimation ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.8).delay(1.5), value: showPhoneAnimation)
                        
                        Text("Your AI Safety Companion")
                            .font(.title3)
                            .foregroundColor(.purple.opacity(0.9))
                            .fontWeight(.medium)
                            .opacity(showPhoneAnimation ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.8).delay(1.7), value: showPhoneAnimation)
                    }
                    
                    // Continue button
                    Button(action: onContinue) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                    }
                    .padding(.horizontal, 40)
                    .opacity(showPhoneAnimation ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(2.0), value: showPhoneAnimation)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            showPhoneAnimation = true
        }
    }
    
    private func completeOnboarding() {
        appState.completeOnboarding()
        dismiss()
    }
}

struct PhoneMockupView: View {
    var body: some View {
        ZStack {
            // Phone frame
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                .frame(width: 170, height: 350)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            // Screen
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .frame(width: 150, height: 320)
                .overlay(
                    // Screen content
                    VStack(spacing: 0) {
                        // Status bar
                        HStack {
                            Text("9:41")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "signal.bars.3.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "wifi")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "battery.100")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        Spacer()
                        
                        // App interface preview
                        VStack(spacing: 20) {
                            // App icon
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                )
                            
                            // Emergency button
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.purple.opacity(0.8), .pink.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                        
                                        Text("SOS")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                        
                        Spacer()
                        
                        // Home indicator
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .padding(.bottom, 8)
                    }
                )
            
            // Notch
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black)
                .frame(width: 30, height: 6)
                .offset(y: -167)
        }
        .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    WelcomeScreenView {
        print("Continue tapped")
    }
    .environmentObject(AppState())
}