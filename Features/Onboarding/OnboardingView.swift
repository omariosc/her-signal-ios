import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Welcome to HerSignal",
            subtitle: "Your AI Safety Companion",
            description: "HerSignal helps you feel safer in public spaces by generating realistic AI phone calls that can deter potential threats.",
            icon: "shield.checkered",
            color: .purple
        ),
        OnboardingPage(
            title: "How It Works",
            subtitle: "Realistic AI Conversations",
            description: "Tap the emergency button to start an AI-generated phone call that sounds like you're talking to a friend, family member, or colleague.",
            icon: "phone.bubble.left",
            color: .blue
        ),
        OnboardingPage(
            title: "Always With You",
            subtitle: "Quick & Discreet Activation",
            description: "One tap is all it takes. The app works instantly without internet and looks like a real phone call to anyone nearby.",
            icon: "bolt.circle",
            color: .orange
        ),
        OnboardingPage(
            title: "Your Privacy Matters",
            subtitle: "Secure & Private",
            description: "Your conversations are never recorded or stored. All AI processing happens locally on your device for maximum privacy.",
            icon: "lock.shield",
            color: .green
        ),
        OnboardingPage(
            title: "Age Verification",
            subtitle: "18+ Only",
            description: "This app is designed for users 18 and older due to safety-related content and features.",
            icon: "person.badge.shield.checkmark",
            color: .red
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [onboardingPages[currentPage].color.opacity(0.1), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                
                // Custom page indicators
                HStack(spacing: 8) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? onboardingPages[currentPage].color : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(onboardingPages[currentPage].color)
                    }
                    
                    Spacer()
                    
                    if currentPage < onboardingPages.count - 1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(onboardingPages[currentPage].color)
                        .fontWeight(.semibold)
                    } else {
                        // Age verification and completion
                        VStack(spacing: 12) {
                            Button("I am 18 or older") {
                                completeOnboarding()
                            }
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(onboardingPages[currentPage].color)
                            )
                            
                            Button("I am under 18") {
                                // Handle under-age users
                                showAgeRestrictionAlert()
                            }
                            .foregroundColor(.gray)
                            .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
            }
        }
    }
    
    private func completeOnboarding() {
        appState.completeOnboarding()
        dismiss()
    }
    
    private func showAgeRestrictionAlert() {
        // In a real implementation, show an alert explaining age restrictions
        // For now, just dismiss the onboarding
        dismiss()
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .symbolEffect(.pulse)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(page.color)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}