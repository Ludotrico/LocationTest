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


class Location: NSObject {
    
    //MARK: Variables
    static let shared = Location()
    static var locationManager: CLLocationManager?
    static var counter = "countt"
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
    
    
    //MARK: Helper Functions
    
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
            deployStrategy()
        case .authorizedWhenInUse:
            print("???Location auth status is AUTHORIZED WHEN IN USE")
        @unknown default:
            print("???Location auth status UNKNOWN")
            fatalError()
            
        }
    }
    
    static func deployStrategy() {
        if useAllStrategies {
            createMultipleRegions()
            Location.locationManager!.startMonitoringSignificantLocationChanges()
        } else if regionHoppingWorkaround {
            createRegion()
        } else if multipleRegionHoppingWorkaround {
            createMultipleRegions()
        } else if significantLocationUpdates {
            Location.locationManager!.startMonitoringSignificantLocationChanges()
        }
    }
    
    
    static func createRegion() {
        Location.stopMonitoringRegions()
        
        let region = CLCircularRegion(center: Location.locationManager!.location!.coordinate, radius: Location.regionRadius, identifier: "lastLocation")
        region.notifyOnExit = true
        region.notifyOnEntry = false
        Location.locationManager!.startMonitoring(for: region)
    }
    
    static func createMultipleRegions() {
        Location.stopMonitoringRegions()
        
        //Can only monitor 20 regions max
        for radius in stride(from: 50, through: 1000, by: 50) {
            let region = CLCircularRegion(center: Location.locationManager!.location!.coordinate, radius: CLLocationDistance(radius), identifier: "\(radius)")
            region.notifyOnExit = true
            region.notifyOnEntry = false
            Location.locationManager!.startMonitoring(for: region)
        }
    }
    
    static func stopMonitoringRegions() {
        for region in Location.locationManager!.monitoredRegions {
            Location.locationManager?.stopMonitoring(for: region)
        }
    }
    
    
    
    func fireNotification(fromRegion: Bool, radius: Int?=nil) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            let content = UNMutableNotificationContent()
            content.title = fromRegion ? "Exited Region" : "didUpdateLocation"
            if fromRegion {
                content.body = "\(radius!) meter region"
            }
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
    
    
    
    
}


//MARK: CLLocationManagerDelegate
extension Location: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            Location.locationManager!.requestAlwaysAuthorization()
        } else if status == .authorizedAlways {
            Location.deployStrategy()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let circularRegion = region as! CLCircularRegion
   
        if multipleRegionHoppingWorkaround || useAllStrategies {
            Location.createMultipleRegions()
        } else if regionHoppingWorkaround {
            Location.createRegion()
        }
        
        
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: Location.counter)+1, forKey: Location.counter)
        
        API.pingServer(date: manager.location!.timestamp, coordinates: manager.location!.coordinate, fromExitRegion: true, radius: Int(circularRegion.radius)) { _ in }
        
        fireNotification(fromRegion: true, radius: Int(circularRegion.radius))
        
        Location.VC.refresh()
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: Location.counter)+1, forKey: Location.counter)
        API.pingServer(date: manager.location!.timestamp, coordinates: manager.location!.coordinate, fromExitRegion: false) { _ in }
        fireNotification(fromRegion: false)
        
        Location.VC.refresh()
    }
    
}


