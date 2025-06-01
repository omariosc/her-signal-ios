import SwiftUI

struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var contacts = [
        EmergencyContact(name: "Maya (AI Companion)", phone: "+1-555-AI-HELP", isPrimary: true),
        EmergencyContact(name: "Emergency Services", phone: "911", isPrimary: false),
        EmergencyContact(name: "Campus Security", phone: "+1-555-CAMPUS", isPrimary: false)
    ]
    @State private var showingAddContact = false
    
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
                        Text("During an emergency:")\n                            .font(.headline)\n                        \n                        Text("• Your primary contact will be called automatically")\n                        Text("• Video recordings will be shared with trusted contacts")\n                        Text("• Location will be sent to emergency services if needed")\n                    }\n                    .font(.caption)\n                    .foregroundColor(.secondary)\n                    .padding(.vertical, 4)\n                }\n            }\n            .navigationTitle("Emergency Contacts")\n            .navigationBarTitleDisplayMode(.large)\n            .toolbar {\n                ToolbarItem(placement: .navigationBarTrailing) {\n                    Button("Done") {\n                        dismiss()\n                    }\n                }\n            }\n        }\n        .sheet(isPresented: $showingAddContact) {\n            AddContactView { newContact in\n                contacts.append(newContact)\n            }\n        }\n    }\n    \n    private func deleteContact(at offsets: IndexSet) {\n        let nonPrimaryContacts = contacts.filter { !$0.isPrimary }\n        for index in offsets {\n            if let contactIndex = contacts.firstIndex(where: { $0.id == nonPrimaryContacts[index].id }) {\n                contacts.remove(at: contactIndex)\n            }\n        }\n    }\n}\n\nstruct ContactRow: View {\n    let contact: EmergencyContact\n    \n    var body: some View {\n        HStack {\n            VStack(alignment: .leading, spacing: 4) {\n                Text(contact.name)\n                    .font(.headline)\n                \n                Text(contact.phone)\n                    .font(.subheadline)\n                    .foregroundColor(.secondary)\n            }\n            \n            Spacer()\n            \n            if contact.isPrimary {\n                Text("PRIMARY")\n                    .font(.caption)\n                    .fontWeight(.bold)\n                    .foregroundColor(.white)\n                    .padding(.horizontal, 8)\n                    .padding(.vertical, 4)\n                    .background(Color.purple)\n                    .clipShape(Capsule())\n            }\n            \n            Button(action: {\n                if let url = URL(string: "tel://\\(contact.phone)") {\n                    UIApplication.shared.open(url)\n                }\n            }) {\n                Image(systemName: "phone.fill")\n                    .foregroundColor(.green)\n            }\n        }\n        .padding(.vertical, 4)\n    }\n}\n\nstruct AddContactView: View {\n    @Environment(\\.dismiss) private var dismiss\n    @State private var name = ""\n    @State private var phone = ""\n    let onAdd: (EmergencyContact) -> Void\n    \n    var body: some View {\n        NavigationView {\n            Form {\n                Section("Contact Information") {\n                    TextField("Name", text: $name)\n                    TextField("Phone Number", text: $phone)\n                        .keyboardType(.phonePad)\n                }\n            }\n            .navigationTitle("Add Contact")\n            .navigationBarTitleDisplayMode(.inline)\n            .toolbar {\n                ToolbarItem(placement: .navigationBarLeading) {\n                    Button("Cancel") {\n                        dismiss()\n                    }\n                }\n                \n                ToolbarItem(placement: .navigationBarTrailing) {\n                    Button("Add") {\n                        let newContact = EmergencyContact(name: name, phone: phone, isPrimary: false)\n                        onAdd(newContact)\n                        dismiss()\n                    }\n                    .disabled(name.isEmpty || phone.isEmpty)\n                }\n            }\n        }\n    }\n}\n\n#Preview {\n    EmergencyContactsView()\n}