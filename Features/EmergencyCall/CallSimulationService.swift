import Foundation
import AVFoundation
import Combine

class CallSimulationService: NSObject, ObservableObject {
    @Published var isCallActive = false
    @Published var callDuration: TimeInterval = 0
    @Published var currentMessage: String?
    @Published var isMuted = false
    @Published var isSpeakerOn = false
    
    private var callTimer: Timer?
    private var messageTimer: Timer?
    private var aiVoiceEngine = AIVoiceEngine()
    private var currentScenario: CallScenario?
    private var messageIndex = 0
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    func startEmergencyCall(scenario: CallScenario) {
        isCallActive = true
        currentScenario = scenario
        messageIndex = 0
        callDuration = 0
        
        // Start call timer
        startCallTimer()
        
        // Begin AI conversation
        beginAIConversation(scenario: scenario)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func endCall() {
        isCallActive = false
        currentMessage = nil
        callTimer?.invalidate()
        messageTimer?.invalidate()
        aiVoiceEngine.stopSpeaking()
        
        // Reset audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func toggleMute() {
        isMuted.toggle()
        // In a real implementation, this would affect microphone input
    }
    
    func toggleSpeaker() {
        isSpeakerOn.toggle()
        // In a real implementation, this would change audio output route
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, 
                                                           mode: .voiceChat,
                                                           options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.callDuration += 1
        }
    }
    
    private func beginAIConversation(scenario: CallScenario) {
        guard let script = scenario.getScript() else { return }
        
        // Start with greeting
        if !script.messages.isEmpty {
            displayAndSpeakMessage(script.messages[0])
            messageIndex = 1
            
            // Schedule next messages
            scheduleNextMessage(script: script)
        }
    }
    
    private func scheduleNextMessage(script: CallScript) {
        // Schedule next message based on realistic conversation timing
        let delay = Double.random(in: 8...15) // 8-15 seconds between messages
        
        messageTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.deliverNextMessage(script: script)
        }
    }
    
    private func deliverNextMessage(script: CallScript) {
        guard isCallActive, messageIndex < script.messages.count else { return }
        
        let message = script.messages[messageIndex]
        displayAndSpeakMessage(message)
        messageIndex += 1
        
        // Schedule next message if available
        if messageIndex < script.messages.count {
            scheduleNextMessage(script: script)
        } else {
            // Conversation complete, continue with periodic responses
            schedulePeriodicResponses(script: script)
        }
    }
    
    private func schedulePeriodicResponses(script: CallScript) {
        // After main script, provide periodic responses to maintain realism
        let delay = Double.random(in: 20...30)
        
        messageTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self, self.isCallActive else { return }
            
            let responses = [
                "Are you doing okay?",
                "I'm still here with you.",
                "How much further do you have to go?",
                "Let me know if you need anything.",
                "I'll stay on the line."
            ]
            
            let randomResponse = responses.randomElement() ?? "I'm here."
            self.displayAndSpeakMessage(randomResponse)
            
            // Schedule next periodic response
            self.schedulePeriodicResponses(script: script)
        }
    }
    
    private func displayAndSpeakMessage(_ message: String) {
        currentMessage = message
        
        // Speak the message using AI voice
        aiVoiceEngine.speakText(message, voice: .maya)
        
        // Clear message after speaking duration (estimate based on text length)
        let speakingDuration = Double(message.count) * 0.1 + 2.0 // Rough estimate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + speakingDuration) { [weak self] in
            self?.currentMessage = nil
        }
    }
}

// MARK: - Call Scenarios and Scripts

enum CallScenario {
    case walkingSafety
    case publicTransport
    case lateNight
    case general
    
    func getScript() -> CallScript? {
        switch self {
        case .walkingSafety:
            return CallScript(
                scenario: self,
                messages: [
                    "Hey! How's your evening walk going?",
                    "The weather looks really nice tonight.",
                    "I'm just getting ready to head out myself.",
                    "Are you still planning to meet up later?",
                    "Oh, I think I see you up ahead!"
                ]
            )
        case .publicTransport:
            return CallScript(
                scenario: self,
                messages: [
                    "Hi! Are you on the bus already?",
                    "I'm running a few minutes late.",
                    "Which stop are you getting off at?",
                    "I'll meet you at the station.",
                    "Text me when you're close!"
                ]
            )
        case .lateNight:
            return CallScript(
                scenario: self,
                messages: [
                    "Hey, just wanted to check in on you.",
                    "I know it's late, but I wanted to make sure you got home safely.",
                    "Did you get an Uber or are you walking?",
                    "I'm here if you need me to stay on the line.",
                    "Almost home?"
                ]
            )
        case .general:
            return CallScript(
                scenario: self,
                messages: [
                    "Hi! How are you doing?",
                    "I was just thinking about you.",
                    "What are you up to right now?",
                    "I'm free to chat for a while.",
                    "Is everything going okay?"
                ]
            )
        }
    }
}

struct CallScript {
    let scenario: CallScenario
    let messages: [String]
}