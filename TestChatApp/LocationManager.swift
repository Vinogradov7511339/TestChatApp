//
//  LocationManager.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 01.11.2021.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {

    static let shared = LocationManager()

    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?

    private override init() {
        super.init()
        requestPermission()
    }

    func requestPermission() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
        }
    }

    func startUpdating() {
        locationManager?.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager?.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        assert(false, error.localizedDescription)
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
}
