//
//  Location.swift
//  LocationTest
//
//  Created by Ludovico Veniani on 8/12/20.
//  Copyright © 2020 Ludovico Verniani. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import CoreMotion
import UserNotifications

class Location: NSObject, CLLocationManagerDelegate {
    static let shared = Location()
    static var locationManager: CLLocationManager?
    static var counter = "count"
    static var motionManager: CMMotionActivityManager?
    static var shouldReportLocationChange = true
    static let regionRadius: CLLocationDistance = 100
    static var VC: ViewController!
    
    static func initializeManager() {
        Location.locationManager = CLLocationManager()
        
        Location.locationManager!.delegate  = Location.shared
        Location.locationManager!.allowsBackgroundLocationUpdates = true
        Location.locationManager!.pausesLocationUpdatesAutomatically = false
        Location.locationManager!.distanceFilter = Location.regionRadius //kCLDistanceFilterNone  //meters
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
            if useAllStrategies {
                createRegion()
                Location.locationManager!.startMonitoringSignificantLocationChanges()
            } else if regionHoppingWorkaround {
                createRegion()
            } else if significantLocationUpdates {
                Location.locationManager!.startMonitoringSignificantLocationChanges()
            }
            
            
            Location.locationManager!.startUpdatingLocation()
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
        
    }
    
    
    
    
    
    static func createRegion() {
        let region = CLCircularRegion(center: Location.locationManager!.location!.coordinate, radius: Location.regionRadius, identifier: "lastLocation")
        region.notifyOnExit = true
        region.notifyOnEntry = false
        Location.locationManager!.startMonitoring(for: region)
    }
    
    static func stopMonitoringRegions() {
        for region in Location.locationManager!.monitoredRegions {
            Location.locationManager?.stopMonitoring(for: region)
        }
    }
    
    
    
    
    
    
    
    
    
    func fireNotification(notificationText: String, fromRegion: Bool) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            let content = UNMutableNotificationContent()
            content.title = fromRegion ? "Exited Region" : "didUpdateLocation"
            //                content.body = notificationText
            content.sound =  .default
            content.badge = NSNumber(value: UserDefaults.standard.integer(forKey: Location.counter))
            content.threadIdentifier = fromRegion ? "fromRegionExit" : "notFromRegionExit"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: "Test", content: content, trigger: trigger)
            
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    // Handle the error
                }
            })
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let circularRegion = region as! CLCircularRegion
        print("@ @ @ DID EXIT REGION: \(circularRegion.center)")
        
        manager.stopMonitoring(for: region) 
        Location.createRegion()
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: Location.counter)+1, forKey: Location.counter)
        
        API.pingServer(date: manager.location!.timestamp, coordinates: manager.location!.coordinate) { _ in }
        fireNotification(notificationText: "didExitRegion", fromRegion: true)
        
        Location.VC.refresh()
        
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: Location.counter)+1, forKey: Location.counter)
        API.pingServer(date: manager.location!.timestamp, coordinates: manager.location!.coordinate) { _ in }
        fireNotification(notificationText: "didUpdateLocation", fromRegion: false)
        
        Location.VC.refresh()
    }
    
}






