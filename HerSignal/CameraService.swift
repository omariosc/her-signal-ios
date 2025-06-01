//
//  CameraService.swift
//  HerSignal
//
//  FaceTime-like camera service with dual recording
//

import SwiftUI
import AVFoundation
import Combine
import Photos

class CameraService: NSObject, ObservableObject {
    @Published var frontSession = AVCaptureSession()
    @Published var backSession = AVCaptureSession()
    @Published var isRecording = false
    @Published var hasPermission = false
    @Published var currentCamera: CameraPosition = .front
    
    enum CameraPosition {
        case front, back
    }
    
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    
    private var frontVideoOutput: AVCaptureVideoDataOutput?
    private var backVideoOutput: AVCaptureVideoDataOutput?
    private var audioInput: AVCaptureDeviceInput?
    
    private var frontWriter: AVAssetWriter?
    private var backWriter: AVAssetWriter?
    private var frontWriterInput: AVAssetWriterInput?
    private var backWriterInput: AVAssetWriterInput?
    private var frontAudioWriterInput: AVAssetWriterInput?
    private var backAudioWriterInput: AVAssetWriterInput?
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let recordingQueue = DispatchQueue(label: "camera.recording.queue")
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                if granted {
                    self?.setupSession()
                }
            }
        }
    }
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.hasPermission = (status == .authorized)
            if self.hasPermission {
                self.setupSession()
            }
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Setup front camera session
            self.frontSession.beginConfiguration()
            if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
               let frontInput = try? AVCaptureDeviceInput(device: frontDevice) {
                self.frontCameraInput = frontInput
                if self.frontSession.canAddInput(frontInput) {
                    self.frontSession.addInput(frontInput)
                }
            }
            
            // Setup back camera session
            self.backSession.beginConfiguration()
            if let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               let backInput = try? AVCaptureDeviceInput(device: backDevice) {
                self.backCameraInput = backInput
                if self.backSession.canAddInput(backInput) {
                    self.backSession.addInput(backInput)
                }
            }
            
            // Setup audio for both sessions
            self.setupAudio()
            
            // Setup video outputs for both sessions
            self.setupVideoOutputs()
            
            self.frontSession.commitConfiguration()
            self.backSession.commitConfiguration()
            
            DispatchQueue.main.async {
                self.frontSession.startRunning()
                self.backSession.startRunning()
            }
        }
    }
    
    private func setupVideoOutputs() {
        frontVideoOutput = AVCaptureVideoDataOutput()
        backVideoOutput = AVCaptureVideoDataOutput()
        
        frontVideoOutput?.setSampleBufferDelegate(self, queue: recordingQueue)
        backVideoOutput?.setSampleBufferDelegate(self, queue: recordingQueue)
        
        if let frontOutput = frontVideoOutput, frontSession.canAddOutput(frontOutput) {
            frontSession.addOutput(frontOutput)
        }
        
        if let backOutput = backVideoOutput, backSession.canAddOutput(backOutput) {
            backSession.addOutput(backOutput)
        }
    }
    
    private func setupAudio() {
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInputDevice = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        
        self.audioInput = audioInputDevice
        
        // Add audio to both sessions
        if frontSession.canAddInput(audioInputDevice) {
            frontSession.addInput(audioInputDevice)
        }
        
        if backSession.canAddInput(audioInputDevice) {
            backSession.addInput(audioInputDevice)
        }
    }
    
    func switchCamera() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentCamera = (self.currentCamera == .front) ? .back : .front
        }
    }
    
    var currentSession: AVCaptureSession {
        return currentCamera == .front ? frontSession : backSession
    }
    
    func startRecording() {
        recordingQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.setupRecording()
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
    
    func stopRecording() {
        recordingQueue.async { [weak self] in
            guard let self = self else { return }
            
            let frontURL = self.frontWriter?.outputURL
            let backURL = self.backWriter?.outputURL
            
            self.frontWriter?.finishWriting {
                if let url = frontURL {
                    self.saveVideoToPhotos(url: url, label: "Front Camera")
                }
            }
            
            self.backWriter?.finishWriting {
                if let url = backURL {
                    self.saveVideoToPhotos(url: url, label: "Back Camera")
                }
            }
            
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
    }
    
    private func saveVideoToPhotos(url: URL, label: String) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .video, fileURL: url, options: nil)
                }) { success, error in
                    if success {
                        print("✅ \(label) video saved to Photos app")
                    } else if let error = error {
                        print("❌ Error saving \(label) video: \(error.localizedDescription)")
                    }
                }
            } else {
                print("❌ Photo library access denied")
            }
        }
    }
    
    private func setupRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = Date().timeIntervalSince1970
        
        // Create HerSignal folder if it doesn't exist
        let herSignalFolder = documentsPath.appendingPathComponent("HerSignal_Recordings")
        try? FileManager.default.createDirectory(at: herSignalFolder, withIntermediateDirectories: true)
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920
        ]
        
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2
        ]
        
        // Setup front camera recording
        let frontURL = herSignalFolder.appendingPathComponent("front_\(timestamp).mp4")
        frontWriter = try? AVAssetWriter(url: frontURL, fileType: .mp4)
        
        frontWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        frontWriterInput?.expectsMediaDataInRealTime = true
        
        frontAudioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        frontAudioWriterInput?.expectsMediaDataInRealTime = true
        
        if let frontWriter = frontWriter {
            if let frontWriterInput = frontWriterInput, frontWriter.canAdd(frontWriterInput) {
                frontWriter.add(frontWriterInput)
            }
            if let frontAudioWriterInput = frontAudioWriterInput, frontWriter.canAdd(frontAudioWriterInput) {
                frontWriter.add(frontAudioWriterInput)
            }
            frontWriter.startWriting()
            frontWriter.startSession(atSourceTime: CMTime.zero)
        }
        
        // Setup back camera recording
        let backURL = herSignalFolder.appendingPathComponent("back_\(timestamp).mp4")
        backWriter = try? AVAssetWriter(url: backURL, fileType: .mp4)
        
        backWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        backWriterInput?.expectsMediaDataInRealTime = true
        
        backAudioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        backAudioWriterInput?.expectsMediaDataInRealTime = true
        
        if let backWriter = backWriter {
            if let backWriterInput = backWriterInput, backWriter.canAdd(backWriterInput) {
                backWriter.add(backWriterInput)
            }
            if let backAudioWriterInput = backAudioWriterInput, backWriter.canAdd(backAudioWriterInput) {
                backWriter.add(backAudioWriterInput)
            }
            backWriter.startWriting()
            backWriter.startSession(atSourceTime: CMTime.zero)
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRecording else { return }
        
        if output == frontVideoOutput {
            if let frontWriterInput = frontWriterInput, frontWriterInput.isReadyForMoreMediaData {
                frontWriterInput.append(sampleBuffer)
            }
        } else if output == backVideoOutput {
            if let backWriterInput = backWriterInput, backWriterInput.isReadyForMoreMediaData {
                backWriterInput.append(sampleBuffer)
            }
        } else {
            // Handle audio from both sessions
            if let frontAudioWriterInput = frontAudioWriterInput, frontAudioWriterInput.isReadyForMoreMediaData {
                frontAudioWriterInput.append(sampleBuffer)
            }
            if let backAudioWriterInput = backAudioWriterInput, backAudioWriterInput.isReadyForMoreMediaData {
                backAudioWriterInput.append(sampleBuffer)
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
        }
    }
}

struct DualCameraPreviewView: View {
    @ObservedObject var cameraService: CameraService
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraService.currentSession)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    // Picture-in-picture preview of other camera
                    CameraPreviewView(session: cameraService.currentCamera == .front ? cameraService.backSession : cameraService.frontSession)
                        .frame(width: 120, height: 160)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                }
                
                Spacer()
                
                HStack(spacing: 30) {
                    Button(action: cameraService.switchCamera) {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        if cameraService.isRecording {
                            cameraService.stopRecording()
                        } else {
                            cameraService.startRecording()
                        }
                    }) {
                        Circle()
                            .fill(cameraService.isRecording ? Color.red : Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
