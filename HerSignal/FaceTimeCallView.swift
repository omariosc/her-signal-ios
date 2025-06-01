//
//  FaceTimeCallView.swift
//  HerSignal
//
//  FaceTime-like interface for emergency calls
//

import SwiftUI
import AVFoundation
import AVKit

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
    @State private var callState: CallState = .connecting
    @State private var showingMinimized = false
    @Environment(\.presentationMode) var presentationMode
    
    enum CallState {
        case connecting
        case active
        case ended
    }
    
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
                        
                        switch callState {
                        case .connecting:
                            Text("Connecting...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black, radius: 2)
                        case .active:
                            Text(formatCallDuration(callDuration))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black, radius: 2)
                        case .ended:
                            Text("Call Ended")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black, radius: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Minimize/PiP button (FaceTime style)
                    Button(action: {
                        showingMinimized.toggle()
                        // In a real app, this would minimize to PiP
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }) {
                        Image(systemName: showingMinimized ? "rectangle.inset.filled" : "minus")
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
                        
                        // Audio device picker button
                        AudioDevicePickerButton()
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
        callState = .connecting
        
        // Start dual camera recording immediately
        cameraService.startRecording()
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            callState = .active
            isCallActive = true
            
            // Start call timer
            callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                callDuration += 1
            }
        }
        
        // Haptic feedback for call start
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    private func endCall() {
        callState = .ended
        isCallActive = false
        callTimer?.invalidate()
        
        // Stop recording
        cameraService.stopRecording()
        
        // Haptic feedback for call end
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        
        // Show "Call Ended" briefly, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioDevicePickerButton: View {
    @State private var showingAudioPicker = false
    
    var body: some View {
        Button(action: {
            showingAudioPicker = true
        }) {
            Image(systemName: "speaker.wave.3.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
                .shadow(color: .black, radius: 4)
        }
        .sheet(isPresented: $showingAudioPicker) {
            AudioDevicePickerView()
        }
    }
}

struct AudioDevicePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var availableDevices = [
        AudioDevice(name: "iPhone", type: .builtin, isSelected: true),
        AudioDevice(name: "Speaker", type: .speaker, isSelected: false),
        AudioDevice(name: "AirPods Pro", type: .bluetooth, isSelected: false),
        AudioDevice(name: "Car Audio", type: .carplay, isSelected: false)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach($availableDevices) { $device in
                    AudioDeviceRow(device: $device) {
                        // Update selection
                        for index in availableDevices.indices {
                            availableDevices[index].isSelected = false
                        }
                        device.isSelected = true
                        
                        // Apply audio route change
                        switchToAudioDevice(device)
                        
                        // Dismiss after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func switchToAudioDevice(_ device: AudioDevice) {
        // In a real implementation, this would change the audio route
        print("Switching to audio device: \(device.name)")
        
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
}

struct AudioDevice: Identifiable {
    let id = UUID()
    let name: String
    let type: AudioDeviceType
    var isSelected: Bool
    
    enum AudioDeviceType {
        case builtin
        case speaker
        case bluetooth
        case carplay
        
        var icon: String {
            switch self {
            case .builtin: return "iphone"
            case .speaker: return "speaker.wave.3"
            case .bluetooth: return "airpods"
            case .carplay: return "car"
            }
        }
    }
}

struct AudioDeviceRow: View {
    @Binding var device: AudioDevice
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: device.type.icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(device.name)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if device.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FaceTimeCallView()
}