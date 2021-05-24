//
//  VTClient.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import Foundation

class VTClient {
    
    struct Auth {
        static var apiKey = "531ecee9a4ccc88dc0f9878fcf2bd4e7"
    }
    
    static var photoInfo:FlickrPhotosSearchResponse!

    
    enum Endpoints {
        
        static let requestBase = "http://www.flickr.com/services/rest"
        static let photosBase = "https://live.staticflickr.com"
        
        case getFlickrPhotosSearch(Double, Double, Int, Int)
        case getPhotosDownload(String, String, String)
        
        var stringValue: String {
            switch self {
            // https://stackoverflow.com/questions/24671709/how-to-get-correct-json-object-from-flickr-api
            case .getFlickrPhotosSearch(let lat, let lon, let page, let perPage): return Endpoints.requestBase +
                "/?&method=flickr.photos.search" + "&api_key=" + Auth.apiKey + "&lat=\(lat)&lon=\(lon)&radius=5&per_page=\(perPage)&page=\(page)&format=json" + "&nojsoncallback=1" // needed to add the nojsoncallback stuff in order to remove "wrapper" - see above stackoverflow reference
            case .getPhotosDownload(let server, let id, let secret): return Endpoints.photosBase + "/\(server)/\(id)_\(secret)_w.jpg"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func requestPhotosList(lat: Double, lon: Double, page: Int, perPage: Int, completion: @escaping (Bool, Error?, Int, Int) -> Void) {
        
        var request = URLRequest(url: Endpoints.getFlickrPhotosSearch(lat, lon, page, perPage).url)
       
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 10
        
        let session = URLSession(configuration: configuration)
       
        let task = session.dataTask(with: request) {
            data, response, error in
           
            guard let data = data else {
                DispatchQueue.main.async {
                   
                    completion(false, error, -1, -1) }
                    return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(FlickrPhotosSearchResponse.self, from: data)
                photoInfo = responseObject
                let pages = photoInfo.photos.pages
                let numPhotos = photoInfo.photos.total
                DispatchQueue.main.async {
                    
                    completion(true, nil, pages, numPhotos)
                }
            } catch {
                DispatchQueue.main.async {
                    
                    completion(false, error, -1, -1)
                }
            }
        }
        task.resume()
    }
    
    class func downloadPhotos(dataController: DataController, pin: Pin, completion: @escaping (Bool, Error?) -> Void) {
       
        for pic in photoInfo.photos.photo {
            
            let request = URLRequest(url: Endpoints.getPhotosDownload(pic.server, pic.id, pic.secret).url)
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10
            let session = URLSession(configuration: configuration)
            let task = session.dataTask(with: request) {
                data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(false, error) }
                        return
                }
                
                let photo = Photo(context: dataController.viewContext)
                photo.file = data
                photo.pin = pin
                // sending the completion each time the task runs refreshes the download, I think.
                DispatchQueue.main.async {
           
            completion(true, nil)
                
        }
            }
            task.resume()
    }
        DispatchQueue.main.async {
    
    completion(true, nil)
        }
    
    
}
}
