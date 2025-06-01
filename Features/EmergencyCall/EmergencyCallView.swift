import SwiftUI

struct EmergencyCallView: View {
    @StateObject private var callService = CallSimulationService()
    @State private var selectedContact = "Maya (Safety Companion)"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Realistic call interface background
            LinearGradient(colors: [.black, .gray.opacity(0.8)], 
                         startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Status bar simulation
                HStack {
                    Text("9:41")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        // Signal bars
                        ForEach(0..<4) { index in
                            Rectangle()
                                .frame(width: 3, height: CGFloat(4 + index * 2))
                                .foregroundColor(.white)
                        }
                        
                        // WiFi icon
                        Image(systemName: "wifi")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        
                        // Battery
                        Image(systemName: "battery.100")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // Contact info
                VStack(spacing: 16) {
                    if !callService.isCallActive {
                        Text("Incoming call...")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                    }
                    
                    // AI avatar
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .pink], 
                                           startPoint: .topLeading, 
                                           endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("👩🏻‍💼")
                                .font(.system(size: 50))
                        )
                        .scaleEffect(callService.isCallActive ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), 
                                 value: callService.isCallActive)
                    
                    Text(selectedContact)
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.light)
                    
                    if callService.isCallActive {
                        Text(formatCallDuration(callService.callDuration))
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Call controls
                if callService.isCallActive {
                    // Active call controls
                    VStack(spacing: 30) {
                        // Conversation display
                        if let currentMessage = callService.currentMessage {
                            Text(currentMessage)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        
                        // Control buttons
                        HStack(spacing: 60) {
                            // Mute button
                            Button(action: { callService.toggleMute() }) {
                                Circle()
                                    .fill(callService.isMuted ? .red : .gray.opacity(0.7))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: callService.isMuted ? "mic.slash.fill" : "mic.fill")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                    )
                            }
                            
                            // End call button
                            Button(action: {
                                callService.endCall()
                                dismiss()
                            }) {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "phone.down.fill")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                    )
                            }
                            
                            // Speaker button
                            Button(action: { callService.toggleSpeaker() }) {
                                Circle()
                                    .fill(callService.isSpeakerOn ? .blue : .gray.opacity(0.7))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                    )
                            }
                        }
                    }
                } else {
                    // Incoming call controls
                    HStack(spacing: 80) {
                        // Decline button
                        Button(action: {
                            dismiss()
                        }) {
                            Circle()
                                .fill(.red)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "phone.down.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                )
                        }
                        
                        // Accept button
                        Button(action: { 
                            callService.startEmergencyCall(scenario: .walkingSafety)
                        }) {
                            Circle()
                                .fill(.green)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                )
                        }
                    }
                }
                
                Spacer()
            }
        }
        .statusBarHidden()
        .onAppear {
            // Auto-answer after 3 seconds if user doesn't interact
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if !callService.isCallActive {
                    callService.startEmergencyCall(scenario: .walkingSafety)
                }
            }
        }
    }
    
    private func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    EmergencyCallView()
}