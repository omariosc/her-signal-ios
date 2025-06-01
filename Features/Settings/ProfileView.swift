import SwiftUI
import CoreLocation

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var permissionService: PermissionService
    
    @State private var userName = ""
    @State private var userAddress = ""
    @State private var showingAddressPicker = false
    @State private var travelLocations: [String] = []
    @State private var showingLocationPicker = false
    @State private var isRemoteSelected = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(userName.prefix(1).uppercased())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text("Profile Setup")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Name Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What is your name?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your name", text: $userName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Address Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What is your address?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if userAddress.isEmpty {
                            Button(action: {
                                showingAddressPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .foregroundColor(.purple)
                                    Text("Add Location")
                                        .foregroundColor(.purple)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.purple, lineWidth: 1)
                                )
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.purple)
                                    Text(userAddress)
                                        .font(.body)
                                    Spacer()
                                    Button("Change") {
                                        showingAddressPicker = true
                                    }
                                    .foregroundColor(.purple)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Travel Locations Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Where do you usually travel?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Remote option
                        HStack {
                            Button(action: {
                                isRemoteSelected.toggle()
                            }) {
                                HStack {
                                    Text("Remote")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if isRemoteSelected {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.purple)
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                        }
                        
                        // Travel locations list
                        ForEach(travelLocations, id: \.self) { location in
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.purple)
                                Text(location)
                                    .font(.body)
                                Spacer()
                                Button(action: {
                                    travelLocations.removeAll { $0 == location }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Add location button
                        Button(action: {
                            showingLocationPicker = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(.purple)
                                Text("Add Location")
                                    .foregroundColor(.purple)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.purple, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Permissions Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy & Permissions")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        PermissionStatusRow(title: "Camera", status: permissionService.cameraPermission)
                        PermissionStatusRow(title: "Microphone", status: permissionService.microphonePermission)
                        PermissionStatusRow(title: "Photos", status: permissionService.photoLibraryPermission)
                        PermissionStatusRow(title: "Location", status: permissionService.locationPermission)
                        PermissionStatusRow(title: "Contacts", status: permissionService.contactsPermission)
                        PermissionStatusRow(title: "Notifications", status: permissionService.notificationPermission)
                        
                        if !permissionService.allPermissionsGranted {
                            Button("Review Permissions") {
                                permissionService.openSettings()
                            }
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddressPicker) {
            LocationPickerView(selectedAddress: $userAddress)
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView { address in
                if !travelLocations.contains(address) {
                    travelLocations.append(address)
                }
            }
        }
        .onAppear {
            loadProfile()
        }
    }
    
    private func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "HerSignal_UserName")
        UserDefaults.standard.set(userAddress, forKey: "HerSignal_UserAddress")
        UserDefaults.standard.set(travelLocations, forKey: "HerSignal_TravelLocations")
        UserDefaults.standard.set(isRemoteSelected, forKey: "HerSignal_IsRemote")
    }
    
    private func loadProfile() {
        userName = UserDefaults.standard.string(forKey: "HerSignal_UserName") ?? ""
        userAddress = UserDefaults.standard.string(forKey: "HerSignal_UserAddress") ?? ""
        travelLocations = UserDefaults.standard.stringArray(forKey: "HerSignal_TravelLocations") ?? []
        isRemoteSelected = UserDefaults.standard.bool(forKey: "HerSignal_IsRemote")
    }
}

struct PermissionStatusRow: View {
    let title: String
    let status: PermissionService.PermissionStatus
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(textColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        switch status {
        case .granted: return "checkmark.circle.fill"
        case .denied, .restricted: return "xmark.circle.fill"
        case .notDetermined: return "clock.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .granted: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        }
    }
    
    private var statusText: String {
        switch status {
        case .granted: return "Granted"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Asked"
        }
    }
    
    private var textColor: Color {
        switch status {
        case .granted: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .granted: return .green.opacity(0.1)
        case .denied, .restricted: return .red.opacity(0.1)
        case .notDetermined: return .orange.opacity(0.1)
        }
    }
}

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAddress: String
    let onLocationSelected: ((String) -> Void)?
    
    @State private var searchText = ""
    @State private var isUsingCurrentLocation = false
    
    init(selectedAddress: Binding<String>) {
        self._selectedAddress = selectedAddress
        self.onLocationSelected = nil
    }
    
    init(onLocationSelected: @escaping (String) -> Void) {
        self._selectedAddress = .constant("")
        self.onLocationSelected = onLocationSelected
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Address")
                        .font(.headline)
                    
                    TextField("Search for an address", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Current location option
                Button(action: {
                    useCurrentLocation()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("Use Current Location")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Save button
                Button(action: {
                    if !searchText.isEmpty {
                        if let onLocationSelected = onLocationSelected {
                            onLocationSelected(searchText)
                        } else {
                            selectedAddress = searchText
                        }
                    }
                    dismiss()
                }) {
                    Text("Save Location")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(searchText.isEmpty)
            }
            .padding()
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func useCurrentLocation() {
        // Simulate getting current location
        let mockLocation = "Current Location"
        searchText = mockLocation
    }
}

#Preview {
    ProfileView()
        .environmentObject(PermissionService())
}