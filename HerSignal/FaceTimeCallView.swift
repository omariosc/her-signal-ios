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
    @State private var isUsingFrontCamera = true
    @State private var callDuration: TimeInterval = 0
    @State private var callTimer: Timer?
    @State private var selectedContact = "Maya (Safety Companion)"
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Camera preview (full screen)
            if cameraService.hasPermission && isCameraOn {
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                // Black background when camera is "off" (still recording)
                Color.black
                    .ignoresSafeArea()
            }
            
            // FaceTime UI overlay
            VStack {
                // Top bar with contact info and call duration
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedContact)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isCallActive {
                            Text(formatCallDuration(callDuration))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Text("Connecting...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Minimize button (FaceTime style)
                    Button(action: {}) {
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Picture-in-picture for self view (FaceTime style)
                HStack {
                    Spacer()
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 160)
                            .overlay(
                                VStack {
                                    if isCameraOn {
                                        Text("You")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "video.slash.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                            .onTapGesture {
                                // Handle self-view tap (could show full screen self view)
                            }
                        
                        Spacer()
                    }
                    .padding(.trailing, 20)
                }
                
                // Bottom control bar (FaceTime style)
                HStack(spacing: 60) {
                    // Mute button
                    Button(action: {
                        isMuted.toggle()
                        // Note: This is visual only, recording continues
                    }) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(isMuted ? Color.red : Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // End call button
                    Button(action: {
                        endCall()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    
                    // Camera toggle button
                    Button(action: {
                        isCameraOn.toggle()
                        // Note: This is visual only, recording continues
                    }) {
                        Image(systemName: isCameraOn ? "video.fill" : "video.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(isCameraOn ? Color.white.opacity(0.2) : Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
                
                // Additional controls row (FaceTime style)
                HStack(spacing: 40) {
                    // Camera flip button
                    Button(action: {
                        cameraService.switchCamera()
                        isUsingFrontCamera.toggle()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // Effects button (placeholder)
                    Button(action: {}) {
                        Image(systemName: "face.smiling.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // Speaker button
                    Button(action: {}) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
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
    }
    
    private func endCall() {
        isCallActive = false
        callTimer?.invalidate()
        cameraService.stopRecording()
        presentationMode.wrappedValue.dismiss()
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