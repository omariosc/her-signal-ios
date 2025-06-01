import Foundation
import SwiftUI
import UIKit

// MARK: - String Extensions

extension String {
    /// Returns a localized string using NSLocalizedString
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
    /// Validates if string is a valid phone number
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[1-9]\\d{1,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self.digitsOnly)
    }
    
    /// Returns only the digits from the string
    var digitsOnly: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    /// Formats phone number for display
    var formattedPhoneNumber: String {
        let cleanNumber = self.digitsOnly
        
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
        
        return self
    }
    
    /// Checks if string is empty or contains only whitespace
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Truncates string to specified length
    func truncated(to length: Int) -> String {
        if count <= length {
            return self
        }
        return String(prefix(length)) + "..."
    }
}

// MARK: - Date Extensions

extension Date {
    /// Returns formatted time string (e.g., "2:30 PM")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Returns formatted date string (e.g., "Jan 15, 2024")
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns relative date string (e.g., "2 hours ago")
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns true if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Returns true if date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Returns time interval since date
    var timeAgo: TimeInterval {
        return Date().timeIntervalSince(self)
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    /// Returns formatted duration string (e.g., "2:30")
    var formattedDuration: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Returns long formatted duration string (e.g., "2 minutes, 30 seconds")
    var longFormattedDuration: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        var components: [String] = []
        
        if hours > 0 {
            components.append("\(hours) hour\(hours == 1 ? "" : "s")")
        }
        
        if minutes > 0 {
            components.append("\(minutes) minute\(minutes == 1 ? "" : "s")")
        }
        
        if seconds > 0 || components.isEmpty {
            components.append("\(seconds) second\(seconds == 1 ? "" : "s")")
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Returns hex string representation of color
    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255))
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a gradient border to the view
    func gradientBorder<S: ShapeStyle>(_ gradient: S, width: CGFloat, cornerRadius: CGFloat) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: width)
            )
    }
    
    /// Applies a glow effect to the view
    func glow(color: Color = .white, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
    
    /// Applies a card-like appearance
    func cardStyle(cornerRadius: CGFloat = Constants.UI.cornerRadius) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), 
                           radius: Constants.UI.shadowRadius, 
                           x: 0, y: 2)
            )
    }
    
    /// Conditional view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Hides the view based on condition
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
    
    /// Adds haptic feedback on tap
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    /// Returns the app's display name
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String ??
               "HerSignal"
    }
    
    /// Returns the app's version
    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    /// Returns the app's build number
    var buildNumber: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    /// Safely sets and synchronizes a value
    func setSafely<T>(_ value: T, forKey key: String) {
        set(value, forKey: key)
        synchronize()
    }
    
    /// Returns a value with a default fallback
    func value<T>(forKey key: String, defaultValue: T) -> T {
        return object(forKey: key) as? T ?? defaultValue
    }
}

// MARK: - URL Extensions

extension URL {
    /// Opens the URL in Safari
    func openInSafari() {
        if UIApplication.shared.canOpenURL(self) {
            UIApplication.shared.open(self)
        }
    }
    
    /// Creates a URL for phone calls
    static func phoneCall(number: String) -> URL? {
        let cleanNumber = number.digitsOnly
        return URL(string: "tel://\(cleanNumber)")
    }
    
    /// Creates a URL for SMS
    static func sms(number: String, body: String? = nil) -> URL? {
        let cleanNumber = number.digitsOnly
        var urlString = "sms:\(cleanNumber)"
        
        if let body = body {
            urlString += "&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        return URL(string: urlString)
    }
}

// MARK: - Array Extensions

extension Array where Element: Equatable {
    /// Removes all instances of an element
    mutating func removeAll(_ element: Element) {
        self = filter { $0 != element }
    }
    
    /// Returns a new array with unique elements
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues.append(item)
            }
        }
        return uniqueValues
    }
}

extension Array where Element: Identifiable {
    /// Finds the index of an element by ID
    func firstIndex(withId id: Element.ID) -> Int? {
        return firstIndex { $0.id == id }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let emergencyActivated = Notification.Name("emergencyActivated")
    static let emergencyDeactivated = Notification.Name("emergencyDeactivated")
    static let locationUpdated = Notification.Name("locationUpdated")
    static let contactsUpdated = Notification.Name("contactsUpdated")
    static let settingsChanged = Notification.Name("settingsChanged")
}