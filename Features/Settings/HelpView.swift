import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("How HerSignal Works")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Your AI-powered safety companion that creates realistic emergency calls while recording evidence")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 20) {
                        HelpSection(
                            icon: "phone.fill",
                            title: "Fake Emergency Calls",
                            description: "Creates realistic phone conversations that look and sound like real emergency calls to deter potential threats"
                        )
                        
                        HelpSection(
                            icon: "video.fill",
                            title: "Dual Camera Recording",
                            description: "Simultaneously records from front and back cameras to capture comprehensive evidence of your surroundings"
                        )
                        
                        HelpSection(
                            icon: "photo.on.rectangle",
                            title: "Auto-Save Evidence",
                            description: "Automatically saves all recordings to your Photos app for easy access and sharing with authorities"
                        )
                        
                        HelpSection(
                            icon: "location.fill",
                            title: "Location Tracking",
                            description: "Shares your location with emergency contacts and can assist first responders if needed"
                        )
                        
                        HelpSection(
                            icon: "brain.head.profile",
                            title: "AI Companion",
                            description: "Maya, your AI safety companion, provides realistic conversation and emotional support during emergencies"
                        )
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Quick Start Guide
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Start Guide")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HelpStep(number: 1, text: "Tap the big purple button to start an emergency call")
                            HelpStep(number: 2, text: "The call will auto-answer and begin recording")
                            HelpStep(number: 3, text: "Act naturally - the AI will handle the conversation")
                            HelpStep(number: 4, text: "End the call when you're safe")
                            HelpStep(number: 5, text: "Recordings are automatically saved to Photos")
                        }
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Safety Tips
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Safety Tips")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Use HerSignal when walking alone, especially at night")
                            Text("• Keep your phone visible so others can see you're on a call")
                            Text("• Practice using the app so you're comfortable in emergencies")
                            Text("• Set up emergency contacts before you need them")
                            Text("• Trust your instincts - if something feels wrong, activate HerSignal")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    // Emergency Resources
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Emergency Resources")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            EmergencyResourceButton(title: "Emergency Services", number: "911", icon: "phone.fill", color: .red)
                            EmergencyResourceButton(title: "Crisis Text Line", number: "Text HOME to 741741", icon: "message.fill", color: .blue)
                            EmergencyResourceButton(title: "National Domestic Violence Hotline", number: "1-800-799-7233", icon: "heart.fill", color: .pink)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpSection: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct HelpStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.purple)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct EmergencyResourceButton: View {
    let title: String
    let number: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            if number.starts(with: "Text") {
                // Handle text message
                if let url = URL(string: "sms:741741&body=HOME") {
                    UIApplication.shared.open(url)
                }
            } else {
                // Handle phone call
                let cleanNumber = number.replacingOccurrences(of: "-", with: "")
                if let url = URL(string: "tel://\(cleanNumber)") {
                    UIApplication.shared.open(url)
                }
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(number)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    HelpView()
}