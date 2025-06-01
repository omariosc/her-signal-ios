//
//  CameraService.swift
//  HerSignal
//
//  FaceTime-like camera service with dual recording
//

import SwiftUI
import AVFoundation
import Combine

class CameraService: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    @Published var hasPermission = false
    
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var currentCameraInput: AVCaptureDeviceInput?
    
    private var frontVideoOutput: AVCaptureVideoDataOutput?
    private var backVideoOutput: AVCaptureVideoDataOutput?
    private var audioOutput: AVCaptureAudioDataOutput?
    
    private var frontWriter: AVAssetWriter?
    private var backWriter: AVAssetWriter?
    private var frontWriterInput: AVAssetWriterInput?
    private var backWriterInput: AVAssetWriterInput?
    private var audioWriterInput: AVAssetWriterInput?
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let recordingQueue = DispatchQueue(label: "camera.recording.queue")
    
    override init() {
        super.init()
        requestCameraPermission()
        setupSession()
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            // Setup front camera
            if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
               let frontInput = try? AVCaptureDeviceInput(device: frontDevice) {
                self.frontCameraInput = frontInput
            }
            
            // Setup back camera
            if let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               let backInput = try? AVCaptureDeviceInput(device: backDevice) {
                self.backCameraInput = backInput
            }
            
            // Start with front camera
            if let frontInput = self.frontCameraInput {
                if self.session.canAddInput(frontInput) {
                    self.session.addInput(frontInput)
                    self.currentCameraInput = frontInput
                }
            }
            
            // Setup video outputs
            self.setupVideoOutputs()
            
            // Setup audio
            self.setupAudio()
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.session.startRunning()
            }
        }
    }
    
    private func setupVideoOutputs() {
        frontVideoOutput = AVCaptureVideoDataOutput()
        backVideoOutput = AVCaptureVideoDataOutput()
        
        frontVideoOutput?.setSampleBufferDelegate(self, queue: recordingQueue)
        backVideoOutput?.setSampleBufferDelegate(self, queue: recordingQueue)
        
        if let frontOutput = frontVideoOutput, session.canAddOutput(frontOutput) {
            session.addOutput(frontOutput)
        }
    }
    
    private func setupAudio() {
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        audioOutput = AVCaptureAudioDataOutput()
        audioOutput?.setSampleBufferDelegate(self, queue: recordingQueue)
        
        if let audioOutput = audioOutput, session.canAddOutput(audioOutput) {
            session.addOutput(audioOutput)
        }
    }
    
    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            if let currentInput = self.currentCameraInput {
                self.session.removeInput(currentInput)
            }
            
            // Switch between front and back
            let newInput = (self.currentCameraInput == self.frontCameraInput) ? self.backCameraInput : self.frontCameraInput
            
            if let newInput = newInput, self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.currentCameraInput = newInput
            }
            
            self.session.commitConfiguration()
        }
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
            
            self.frontWriter?.finishWriting { }
            self.backWriter?.finishWriting { }
            
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
    }
    
    private func setupRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Setup front camera recording
        let frontURL = documentsPath.appendingPathComponent("front_\(Date().timeIntervalSince1970).mp4")
        frontWriter = try? AVAssetWriter(url: frontURL, fileType: .mp4)
        
        let frontVideoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920
        ]
        
        frontWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: frontVideoSettings)
        frontWriterInput?.expectsMediaDataInRealTime = true
        
        if let frontWriter = frontWriter, let frontWriterInput = frontWriterInput {
            if frontWriter.canAdd(frontWriterInput) {
                frontWriter.add(frontWriterInput)
            }
            frontWriter.startWriting()
            frontWriter.startSession(atSourceTime: CMTime.zero)
        }
        
        // Setup back camera recording (similar setup)
        let backURL = documentsPath.appendingPathComponent("back_\(Date().timeIntervalSince1970).mp4")
        backWriter = try? AVAssetWriter(url: backURL, fileType: .mp4)
        
        backWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: frontVideoSettings)
        backWriterInput?.expectsMediaDataInRealTime = true
        
        if let backWriter = backWriter, let backWriterInput = backWriterInput {
            if backWriter.canAdd(backWriterInput) {
                backWriter.add(backWriterInput)
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
        } else if output == audioOutput {
            // Append audio to both recordings
            if let frontWriterInput = frontWriterInput, frontWriterInput.isReadyForMoreMediaData {
                frontWriterInput.append(sampleBuffer)
            }
            if let backWriterInput = backWriterInput, backWriterInput.isReadyForMoreMediaData {
                backWriterInput.append(sampleBuffer)
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
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}