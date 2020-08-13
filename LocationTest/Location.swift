//
//  Location.swift
//  LocationTest
//
//  Created by Ludovico Veniani on 8/12/20.
//  Copyright © 2020 Ludovico Verniani. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, CLLocationManagerDelegate  {
    static let shared = Location()
    static var locationManager: CLLocationManager?
    
    
    static func initializeManager() {
        Location.locationManager = CLLocationManager()        
        Location.locationManager!.delegate  = Location.shared
        Location.locationManager!.allowsBackgroundLocationUpdates = true
        Location.locationManager!.pausesLocationUpdatesAutomatically = false
        Location.locationManager!.distanceFilter = 10 //kCLDistanceFilterNone  //meters
        Location.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        enableLocationServices()
    }
    
    static func enableLocationServices() {
        print("???Enable location services)")
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("???Location auth status is NOT DETERMINED")
            Location.locationManager!.requestWhenInUseAuthorization()
        case .restricted:
            print("???Location auth status is RESTRICTED")
            Location.locationManager!.requestWhenInUseAuthorization()
        case .denied:
            print("???Location auth status is DENIED")
            Location.locationManager!.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("???Location auth status is AUTHORIZED ALWAYS")
            Location.locationManager!.startMonitoringSignificantLocationChanges()
        case .authorizedWhenInUse:
            print("???Location auth status is AUTHORIZED WHEN IN USE")
        @unknown default:
            print("???Location auth status UNKNOWN")
            fatalError()
            
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            Location.locationManager!.requestAlwaysAuthorization()
        }
        
        if (status == .authorizedAlways) {
            Location.locationManager!.startMonitoringSignificantLocationChanges()
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error)")
    }
    
    
    
}
