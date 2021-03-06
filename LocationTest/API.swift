//
//  API.swift
//  LocationTest
//
//  Created by Ludovico Veniani on 8/14/20.
//  Copyright © 2020 Ludovico Verniani. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class API {
    static func pingServer(date: Date, coordinates: CLLocationCoordinate2D, fromExitRegion: Bool, radius: Int?=nil, completion: @escaping(Result<Int, Error>) -> ()) {
        var paramaters: [String: Any] = [:]
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd_HH:mm"
        
        paramaters["date"] = format.string(from: date)
        paramaters["latitude"] = coordinates.latitude
        paramaters["longitude"] = coordinates.longitude
        paramaters["exitedRegion"] = fromExitRegion
        if let radius = radius {
            paramaters["radius"] = radius
        } else {
            paramaters["radius"] = nil
        }
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            AF.request("https://[myserver]/temp", method: .post, parameters: paramaters, encoding: JSONEncoding.default)
                .response { response in
                    if response.error == nil {
                        completion(.success(1))
                    } else {
                        completion(.failure(response.error!))
                    }
                    
            }
        }
    }
}
