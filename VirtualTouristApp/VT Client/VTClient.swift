//
//  VTClient.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import Foundation

class VTClient {
    
    struct Auth {
        static var apiKey = "PUT API KEY HERE"
    }
    
    enum Endpoints {
        
        static let base = "http://www.flickr.com/services/rest"
        
        case getFlickrPhotosSearch(Double, Double, Int, Int)
        
        var stringValue: String {
            switch self {
            case .getFlickrPhotosSearch(let lat, let lon, let page, let perPage): return Endpoints.base + "/?&method=flickr.photos.search" + "&api_key=" + Auth.apiKey + "&lat=\(lat) + &lon=\(lon) + &per_page=\(perPage) &page=\(page)"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func requestPhotosFromFlickr() {
        
    }
    
    
    
}
