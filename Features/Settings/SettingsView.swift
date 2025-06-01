import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                Section("Recording Settings") {
                    HStack {
                        Image(systemName: "video.fill")
                            .foregroundColor(.purple)
                        Text("Auto-save to Photos")
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "camera.rotate")
                            .foregroundColor(.purple)
                        Text("Dual Camera Recording")
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                
                Section("Privacy & Security") {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.purple)
                        Text("End-to-End Encryption")
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.purple)
                        Text("Location Services")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("Emergency Features") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.purple)
                        Text("Auto-Answer Calls")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.purple)
                        Text("Background Recording")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.purple)
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.purple)
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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

#Preview {
    SettingsView()
        .environmentObject(AppState())
}