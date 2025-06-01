//
//  ContentView.swift
//  HerSignal
//
//  Created by Omar Choudhry on 01/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEmergencyCall = false
    
    var body: some View {
        ZStack {
            // Main interface
            VStack(spacing: 30) {
                // App logo and title
                VStack(spacing: 16) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("HerSignal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your AI Safety Companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Emergency activation button
                Button(action: {
                    triggerEmergencyCall()
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("Start Safety Call")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(width: 200, height: 200)
                    .background(
                        Circle()
                            .fill(LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .scaleEffect(showingEmergencyCall ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: showingEmergencyCall)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Quick access buttons
                HStack(spacing: 20) {
                    QuickActionButton(
                        icon: "gearshape.fill",
                        title: "Settings",
                        action: { /* Navigate to settings */ }
                    )
                    
                    QuickActionButton(
                        icon: "person.2.fill",
                        title: "Contacts",
                        action: { /* Navigate to emergency contacts */ }
                    )
                    
                    QuickActionButton(
                        icon: "questionmark.circle.fill",
                        title: "Help",
                        action: { /* Show help/tutorial */ }
                    )
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingEmergencyCall) {
            FaceTimeCallView()
        }
    }
    
    private func triggerEmergencyCall() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        showingEmergencyCall = true
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 70, height: 70)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
