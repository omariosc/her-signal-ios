import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var isAuthorized = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentAddress: String?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        
        // Set initial authorization status
        authorizationStatus = locationManager.authorizationStatus
        updateAuthorizationStatus()
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Guide user to settings
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        guard isAuthorized else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentAddress() async -> String? {
        guard let location = currentLocation else { return nil }
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            let address = placemarks.first?.formattedAddress
            
            DispatchQueue.main.async { [weak self] in
                self?.currentAddress = address
            }
            
            return address
        } catch {
            print("Geocoding error: \(error)")
            return nil
        }
    }
    
    private func updateAuthorizationStatus() {
        isAuthorized = authorizationStatus == .authorizedWhenInUse || 
                      authorizationStatus == .authorizedAlways
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        // Update address asynchronously
        Task {
            await getCurrentAddress()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        updateAuthorizationStatus()
        
        if isAuthorized {
            startLocationUpdates()
        } else {
            stopLocationUpdates()
        }
    }
}

extension CLPlacemark {
    var formattedAddress: String {
        var components: [String] = []
        
        if let streetNumber = subThoroughfare {
            components.append(streetNumber)
        }
        
        if let streetName = thoroughfare {
            components.append(streetName)
        }
        
        if let city = locality {
            components.append(city)
        }
        
        if let state = administrativeArea {
            components.append(state)
        }
        
        if let postalCode = postalCode {
            components.append(postalCode)
        }
        
        return components.joined(separator: ", ")
    }
}