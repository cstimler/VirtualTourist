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
    
    static var photoInfo:FlickrPhotosSearchResponse!
    
    enum Endpoints {
        
        static let base = "http://www.flickr.com/services/rest"
        
        case getFlickrPhotosSearch(Double, Double, Int, Int)
        
        var stringValue: String {
            switch self {
            case .getFlickrPhotosSearch(let lat, let lon, let page, let perPage): return Endpoints.base + "/?&method=flickr.photos.search" + "&api_key=" + Auth.apiKey + "&lat=\(lat)&lon=\(lon)&radius=5 &per_page=\(perPage)&page=\(page)&format=json"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func requestPhotosList(lat: Double, lon: Double, page: Int, perPage: Int, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.getFlickrPhotosSearch(lat, lon, page, perPage).url)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) {
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error) }
                    return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(FlickrPhotosSearchResponse.self, from: data)
                photoInfo = responseObject
                DispatchQueue.main.async {
                    
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
}
