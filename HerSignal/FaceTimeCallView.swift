//
//  FaceTimeCallView.swift
//  HerSignal
//
//  FaceTime-like interface for emergency calls
//

import SwiftUI
import AVFoundation

struct FaceTimeCallView: View {
    @StateObject private var cameraService = CameraService()
    @State private var isCallActive = false
    @State private var isCameraOn = true
    @State private var isMuted = false
    @State private var isSpeakerOn = false
    @State private var isUsingFrontCamera = true
    @State private var callDuration: TimeInterval = 0
    @State private var callTimer: Timer?
    @State private var selectedContact = "Maya (Safety Companion)"
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Dual camera preview (full screen with PiP) - Always recording
            if cameraService.hasPermission {
                if isCameraOn {
                    DualCameraPreviewView(cameraService: cameraService)
                        .ignoresSafeArea()
                } else {
                    // Black overlay but still recording underneath
                    ZStack {
                        DualCameraPreviewView(cameraService: cameraService)
                            .ignoresSafeArea()
                            .opacity(0) // Hidden but still recording
                        
                        Color.black
                            .ignoresSafeArea()
                            .overlay(
                                VStack {
                                    Image(systemName: "video.slash.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("Camera Off")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            )
                    }
                }
            } else {
                Color.black
                    .ignoresSafeArea()
                    .overlay(
                        Text("Camera Access Required")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
            }
            
            // FaceTime UI overlay
            VStack {
                // Top bar with contact info and call duration
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedContact)
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                        
                        if isCallActive {
                            Text(formatCallDuration(callDuration))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black, radius: 2)
                        } else {
                            Text("Connecting...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black, radius: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Minimize button (FaceTime style)
                    Button(action: {}) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.4), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .ignoresSafeArea(edges: .top)
                )
                
                Spacer()
                
                // Bottom control bar (FaceTime style)
                VStack(spacing: 20) {
                    HStack(spacing: 60) {
                        // Mute button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isMuted.toggle()
                                
                                // Haptic feedback
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        }) {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(isMuted ? Color.red : Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .scaleEffect(isMuted ? 1.1 : 1.0)
                                .shadow(color: .black, radius: 4)
                        }
                        
                        // End call button
                        Button(action: {
                            endCall()
                        }) {
                            Image(systemName: "phone.down.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: .black, radius: 6)
                        }
                        
                        // Camera toggle button (visual only - recording continues)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isCameraOn.toggle()
                                
                                // Haptic feedback
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        }) {
                            Image(systemName: isCameraOn ? "video.fill" : "video.slash.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(isCameraOn ? Color.black.opacity(0.6) : Color.red)
                                .clipShape(Circle())
                                .scaleEffect(isCameraOn ? 1.0 : 1.1)
                                .shadow(color: .black, radius: 4)
                        }
                    }
                }
                .padding(.bottom, 50)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)
                    .ignoresSafeArea(edges: .bottom)
                )
                
                    // Additional controls row (FaceTime style)
                    HStack(spacing: 40) {
                        // Camera flip button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                cameraService.switchCamera()
                                isUsingFrontCamera.toggle()
                                
                                // Haptic feedback
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        }) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .rotationEffect(.degrees(isUsingFrontCamera ? 0 : 180))
                                .shadow(color: .black, radius: 4)
                        }
                        
                        // Recording indicator
                        Button(action: {
                            // Show recording status
                            let feedback = UINotificationFeedbackGenerator()
                            feedback.notificationOccurred(.success)
                        }) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .opacity(cameraService.isRecording ? 1.0 : 0.3)
                                    .scaleEffect(cameraService.isRecording ? 1.0 : 0.5)
                                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: cameraService.isRecording)
                                
                                Text("REC")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(cameraService.isRecording ? .red : .white)
                            }
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 4)
                        }
                        
                        // Speaker button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isSpeakerOn.toggle()
                                
                                // Haptic feedback
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                        }) {
                            Image(systemName: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(isSpeakerOn ? Color.blue : Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .scaleEffect(isSpeakerOn ? 1.1 : 1.0)
                                .shadow(color: .black, radius: 4)
                        }
                    }
                    .padding(.bottom, 30)
            }
        }
        .statusBarHidden()
        .onAppear {
            startCall()
        }
        .onDisappear {
            endCall()
        }
    }
    
    private func startCall() {
        isCallActive = true
        
        // Start dual camera recording immediately
        cameraService.startRecording()
        
        // Start call timer
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            callDuration += 1
        }
        
        // Haptic feedback for call start
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    private func endCall() {
        isCallActive = false
        callTimer?.invalidate()
        
        // Stop recording
        cameraService.stopRecording()
        
        // Haptic feedback for call end
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        
        // Show confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    FaceTimeCallView()
}