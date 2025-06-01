import SwiftUI
import Contacts

struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var contacts = [
        EmergencyContact(name: "Maya (AI Companion)", phone: "+1-555-AI-HELP", isPrimary: true),
        EmergencyContact(name: "Emergency Services", phone: "911", isPrimary: false)
    ]
    @State private var showingAddContact = false
    @State private var showingContactImport = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Primary Contact") {
                    ForEach(contacts.filter { $0.isPrimary }) { contact in
                        ContactRow(contact: contact)
                    }
                }
                
                Section("Emergency Contacts") {
                    ForEach(contacts.filter { !$0.isPrimary }) { contact in
                        ContactRow(contact: contact)
                    }
                    .onDelete(perform: deleteContact)
                    
                    Button(action: { showingContactImport = true }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.purple)
                            Text("Import from Contacts")
                                .foregroundColor(.purple)
                        }
                    }
                    
                    Button(action: { showingAddContact = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.purple)
                            Text("Add Emergency Contact")
                                .foregroundColor(.purple)
                        }
                    }
                }
                
                Section("Instructions") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("During an emergency:")
                            .font(.headline)
                        
                        Text("• Your primary contact will be called automatically")
                        Text("• Video recordings will be shared with trusted contacts")
                        Text("• Location will be sent to emergency services if needed")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Emergency Contacts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView { newContact in
                contacts.append(newContact)
            }
        }
        .sheet(isPresented: $showingContactImport) {
            ContactImportView { selectedContacts in
                for contact in selectedContacts {
                    if !contacts.contains(where: { $0.name == contact.name }) {
                        contacts.append(contact)
                    }
                }
            }
        }
    }
    
    private func deleteContact(at offsets: IndexSet) {
        let nonPrimaryContacts = contacts.filter { !$0.isPrimary }
        for index in offsets {
            if let contactIndex = contacts.firstIndex(where: { $0.id == nonPrimaryContacts[index].id }) {
                contacts.remove(at: contactIndex)
            }
        }
    }
}

struct ContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                
                Text(contact.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if contact.isPrimary {
                Text("PRIMARY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
            
            Button(action: {
                if let url = URL(string: "tel://\(contact.phone)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""
    let onAdd: (EmergencyContact) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newContact = EmergencyContact(name: name, phone: phone, isPrimary: false)
                        onAdd(newContact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

struct ContactImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var availableContacts: [CNContact] = []
    @State private var selectedContacts: [EmergencyContact] = []
    @State private var isLoading = true
    let onImport: ([EmergencyContact]) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Contacts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if availableContacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No Contacts Found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Please add contacts to your address book first")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(availableContacts, id: \.identifier) { contact in
                            ContactImportRow(
                                contact: contact,
                                isSelected: selectedContacts.contains { $0.name == formatContactName(contact) },
                                onToggle: { isSelected in
                                    let emergencyContact = EmergencyContact(
                                        name: formatContactName(contact),
                                        phone: getContactPhone(contact),
                                        isPrimary: false
                                    )
                                    
                                    if isSelected {
                                        selectedContacts.append(emergencyContact)
                                    } else {
                                        selectedContacts.removeAll { $0.name == emergencyContact.name }
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Import Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        onImport(selectedContacts)
                        dismiss()
                    }
                    .disabled(selectedContacts.isEmpty)
                }
            }
        }
        .onAppear {
            loadContacts()
        }
    }
    
    private func loadContacts() {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        var contacts: [CNContact] = []
        
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                if !contact.phoneNumbers.isEmpty {
                    contacts.append(contact)
                }
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
        
        DispatchQueue.main.async {
            self.availableContacts = contacts
            self.isLoading = false
        }
    }
    
    private func formatContactName(_ contact: CNContact) -> String {
        let firstName = contact.givenName
        let lastName = contact.familyName
        
        if !firstName.isEmpty && !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        } else if !firstName.isEmpty {
            return firstName
        } else if !lastName.isEmpty {
            return lastName
        } else {
            return "Unknown Contact"
        }
    }
    
    private func getContactPhone(_ contact: CNContact) -> String {
        return contact.phoneNumbers.first?.value.stringValue ?? ""
    }
}

struct ContactImportRow: View {
    let contact: CNContact
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatContactName())
                    .font(.headline)
                
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    Text(phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                onToggle(!isSelected)
            }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .secondary)
                    .font(.title2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle(!isSelected)
        }
    }
    
    private func formatContactName() -> String {
        let firstName = contact.givenName
        let lastName = contact.familyName
        
        if !firstName.isEmpty && !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        } else if !firstName.isEmpty {
            return firstName
        } else if !lastName.isEmpty {
            return lastName
        } else {
            return "Unknown Contact"
        }
    }
}

#Preview {
    EmergencyContactsView()
}