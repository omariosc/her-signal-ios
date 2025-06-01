# HerSignal iOS App

This directory contains the iOS application files for HerSignal.

## Setup Instructions

1. **Open Xcode** (version 15 or later)
2. **Create New Project**:
   - Choose "iOS" → "App"
   - Product Name: "HerSignal"
   - Bundle ID: "com.hersignal.app"
   - Language: Swift
   - Interface: SwiftUI
   - Use Core Data: Yes

3. **Replace default files** with the ones provided in this directory
4. **Configure permissions** in Info.plist
5. **Build and run** the project

## Project Structure

This follows the structure outlined in the main Swift.md guide:

```
HerSignal.xcodeproj/
HerSignal/
├── App/
│   ├── HerSignalApp.swift
│   ├── ContentView.swift
│   └── AppState.swift
├── Features/
│   ├── EmergencyCall/
│   ├── Onboarding/
│   └── Settings/
├── Core/
│   ├── Services/
│   ├── Models/
│   └── Utils/
└── Resources/
    ├── Assets.xcassets
    ├── Info.plist
    └── Localizable.strings
```

## Next Steps

1. Follow the Swift.md development roadmap
2. Implement core features phase by phase
3. Test with target users
4. Submit to App Store

## Important Notes

⚠️ **Privacy First**: All user data must be encrypted and stored locally when possible.
🔒 **Security**: Never log or store audio from real emergency situations.
🎯 **User Testing**: Test extensively with target demographic under realistic stress conditions.