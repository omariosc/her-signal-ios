import Foundation
import Contacts

struct EmergencyContact: Codable, Identifiable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var relationship: ContactRelationship
    var isPrimary: Bool
    var shouldReceiveLocationUpdates: Bool
    var shouldReceiveEmergencyAlerts: Bool
    var notes: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var displayName: String {
        if !firstName.isEmpty || !lastName.isEmpty {
            return fullName
        }
        return phoneNumber
    }
    
    init(
        firstName: String = "",
        lastName: String = "",
        phoneNumber: String,
        relationship: ContactRelationship = .friend,
        isPrimary: Bool = false,
        shouldReceiveLocationUpdates: Bool = false,
        shouldReceiveEmergencyAlerts: Bool = true,
        notes: String? = nil
    ) {
        self.id = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.shouldReceiveLocationUpdates = shouldReceiveLocationUpdates
        self.shouldReceiveEmergencyAlerts = shouldReceiveEmergencyAlerts
        self.notes = notes
    }
    
    // Initialize from CNContact
    init(from cnContact: CNContact, relationship: ContactRelationship = .friend) {
        self.id = cnContact.identifier
        self.firstName = cnContact.givenName
        self.lastName = cnContact.familyName
        self.phoneNumber = cnContact.phoneNumbers.first?.value.stringValue ?? ""
        self.relationship = relationship
        self.isPrimary = false
        self.shouldReceiveLocationUpdates = false
        self.shouldReceiveEmergencyAlerts = true
        self.notes = nil
    }
    
    func formattedPhoneNumber() -> String {
        let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleanNumber.count == 10 {
            let areaCode = String(cleanNumber.prefix(3))
            let exchange = String(cleanNumber.dropFirst(3).prefix(3))
            let number = String(cleanNumber.suffix(4))
            return "(\(areaCode)) \(exchange)-\(number)"
        } else if cleanNumber.count == 11 && cleanNumber.hasPrefix("1") {
            let areaCode = String(cleanNumber.dropFirst().prefix(3))
            let exchange = String(cleanNumber.dropFirst(4).prefix(3))
            let number = String(cleanNumber.suffix(4))
            return "+1 (\(areaCode)) \(exchange)-\(number)"
        }
        
        return phoneNumber
    }
    
    func isValidPhoneNumber() -> Bool {
        let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanNumber.count >= 10 && cleanNumber.count <= 15
    }
}

enum ContactRelationship: String, CaseIterable, Codable {
    case family = "Family"
    case friend = "Friend"
    case partner = "Partner"
    case colleague = "Colleague"
    case roommate = "Roommate"
    case neighbor = "Neighbor"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .family: return "house.fill"
        case .friend: return "person.2.fill"
        case .partner: return "heart.fill"
        case .colleague: return "briefcase.fill"
        case .roommate: return "bed.double.fill"
        case .neighbor: return "building.2.fill"
        case .other: return "person.fill"
        }
    }
    
    var description: String {
        return self.rawValue
    }
}

// MARK: - Emergency Contact Manager

class EmergencyContactManager: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    
    private let secureStorage = SecureStorage()
    private let contactStore = CNContactStore()
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        do {
            contacts = try secureStorage.retrieveEmergencyContacts()
        } catch SecureStorage.StorageError.itemNotFound {
            // No contacts stored yet
            contacts = []
        } catch {
            print("Failed to load emergency contacts: \(error)")
            contacts = []
        }
    }
    
    func saveContacts() {
        do {
            try secureStorage.storeEmergencyContacts(contacts)
        } catch {
            print("Failed to save emergency contacts: \(error)")
        }
    }
    
    func addContact(_ contact: EmergencyContact) {
        // Ensure only one primary contact
        var newContact = contact
        if newContact.isPrimary {
            for index in contacts.indices {
                contacts[index].isPrimary = false
            }
        }
        
        contacts.append(newContact)
        saveContacts()
    }
    
    func updateContact(_ contact: EmergencyContact) {
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else { return }
        
        // Ensure only one primary contact
        var updatedContact = contact
        if updatedContact.isPrimary {
            for i in contacts.indices where i != index {
                contacts[i].isPrimary = false
            }
        }
        
        contacts[index] = updatedContact
        saveContacts()
    }
    
    func removeContact(_ contact: EmergencyContact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
    
    func setPrimaryContact(_ contact: EmergencyContact) {
        for index in contacts.indices {
            contacts[index].isPrimary = (contacts[index].id == contact.id)
        }
        saveContacts()
    }
    
    func getPrimaryContact() -> EmergencyContact? {
        return contacts.first { $0.isPrimary }
    }
    
    func getContactsForEmergencyAlert() -> [EmergencyContact] {
        return contacts.filter { $0.shouldReceiveEmergencyAlerts }
    }
    
    func getContactsForLocationUpdates() -> [EmergencyContact] {
        return contacts.filter { $0.shouldReceiveLocationUpdates }
    }
    
    func requestContactsAccess() async -> Bool {
        do {
            let granted = try await contactStore.requestAccess(for: .contacts)
            return granted
        } catch {
            print("Failed to request contacts access: \(error)")
            return false
        }
    }
    
    func importFromContacts() async -> [CNContact] {
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactIdentifierKey
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        var importedContacts: [CNContact] = []
        
        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                if !contact.phoneNumbers.isEmpty {
                    importedContacts.append(contact)
                }
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
        
        return importedContacts
    }
}