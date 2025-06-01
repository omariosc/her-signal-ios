import Foundation
import AVFoundation

class AIVoiceEngine: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speakText(_ text: String, voice: VoicePersona = .maya) {
        guard !text.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice characteristics
        utterance.voice = selectVoice(for: voice)
        utterance.rate = voice.speechRate
        utterance.pitchMultiplier = voice.pitchMultiplier
        utterance.volume = 0.8
        
        // Add natural pauses
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.3
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
    }
    
    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }
    
    private func selectVoice(for persona: VoicePersona) -> AVSpeechSynthesisVoice? {
        let preferredVoices = persona.preferredVoiceIdentifiers
        
        // Try to find the preferred voice
        for identifier in preferredVoices {
            if let voice = AVSpeechSynthesisVoice(identifier: identifier) {
                return voice
            }
        }
        
        // Fallback to language-based selection
        return AVSpeechSynthesisVoice(language: persona.language)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AIVoiceEngine: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
}

// MARK: - Voice Personas

enum VoicePersona {
    case maya
    case friend
    case family
    case professional
    
    var pitchMultiplier: Float {
        switch self {
        case .maya: return 1.1
        case .friend: return 1.0
        case .family: return 0.9
        case .professional: return 0.95
        }
    }
    
    var speechRate: Float {
        switch self {
        case .maya: return 0.5
        case .friend: return 0.52
        case .family: return 0.48
        case .professional: return 0.5
        }
    }
    
    var language: String {
        switch self {
        case .maya: return "en-US"
        case .friend: return "en-GB"
        case .family: return "en-AU"
        case .professional: return "en-US"
        }
    }
    
    var preferredVoiceIdentifiers: [String] {
        switch self {
        case .maya:
            return [
                "com.apple.voice.premium.en-US.Zoe",
                "com.apple.voice.enhanced.en-US.Samantha",
                "com.apple.ttsbundle.Samantha-premium"
            ]
        case .friend:
            return [
                "com.apple.voice.premium.en-GB.Serena",
                "com.apple.voice.enhanced.en-GB.Kate",
                "com.apple.ttsbundle.Kate-premium"
            ]
        case .family:
            return [
                "com.apple.voice.premium.en-AU.Karen",
                "com.apple.voice.enhanced.en-AU.Catherine",
                "com.apple.ttsbundle.Catherine-premium"
            ]
        case .professional:
            return [
                "com.apple.voice.premium.en-US.Ava",
                "com.apple.voice.enhanced.en-US.Allison",
                "com.apple.ttsbundle.Allison-premium"
            ]
        }
    }
    
    var displayName: String {
        switch self {
        case .maya: return "Maya"
        case .friend: return "Friend"
        case .family: return "Family"
        case .professional: return "Professional"
        }
    }
    
    var description: String {
        switch self {
        case .maya: return "Warm, supportive AI companion"
        case .friend: return "Casual, friendly conversation partner"
        case .family: return "Caring, familiar voice"
        case .professional: return "Clear, professional tone"
        }
    }
}