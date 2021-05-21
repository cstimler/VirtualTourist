//
//  VTClient.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import Foundation

class VTClient {
    
    struct Auth {
        static var apiKey = "MYKEY"
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
                "/?&method=flickr.photos.search" + "&api_key=" + Auth.apiKey + "&lat=\(lat)&lon=\(lon)&radius=5&per_page=\(perPage)&page=\(page)&format=json" + "&nojsoncallback=1" // needed to add the nojsoncallback stuff
            case .getPhotosDownload(let server, let id, let secret): return Endpoints.photosBase + "/\(server)/\(id)_\(secret)_w.jpg"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func requestPhotosList(lat: Double, lon: Double, page: Int, perPage: Int, completion: @escaping (Bool, Error?) -> Void) {
        print("1111")
        print(Endpoints.getFlickrPhotosSearch(lat, lon, page, perPage).url)
        print("1122")
        var request = URLRequest(url: Endpoints.getFlickrPhotosSearch(lat, lon, page, perPage).url)
        print("2222")
        let configuration = URLSessionConfiguration.default
        print("3a")
        configuration.timeoutIntervalForRequest = 5
        print("4a")
        let session = URLSession(configuration: configuration)
        print("5a")
        let task = session.dataTask(with: request) {
            data, response, error in
            print("6a")
            guard let data = data else {
                DispatchQueue.main.async {
                    print("Error #1")
                    completion(false, error) }
                    return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(FlickrPhotosSearchResponse.self, from: data)
                photoInfo = responseObject
                DispatchQueue.main.async {
                    print("Non-error #2")
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error #2!")
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func downloadPhotos(dataController: DataController, pin: Pin, completion: @escaping (Bool, Error?) -> Void) {
        print("Enters into downloadPhotos")
        for pic in photoInfo.photos.photo {
            print("3333")
            let request = URLRequest(url: Endpoints.getPhotosDownload(pic.server, pic.id, pic.secret).url)
            print("4444")
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
                print("Gets into after for-in loop")
                let photo = Photo(context: dataController.viewContext)
                photo.file = data
                photo.pin = pin
                // sending the completion each time refreshes the download, I think.
                DispatchQueue.main.async {
            print("SENDING THE COMPLETION NOW")
            completion(true, nil)
                
        }
            }
            task.resume()
    }
        DispatchQueue.main.async {
    print("SENDING THE COMPLETION NOW")
    completion(true, nil)
        }
    
    
}
}
