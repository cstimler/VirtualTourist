//
//  FlickrPhotosSearchResponse.swift
//  VirtualTouristApp
//
//  Created by June2020 on 5/18/21.
//

import Foundation

struct Photos: Codable {
    var id: String
    var secret: String
    var server: String
    var farm: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case secret
        case server
        case farm
    }
}

struct PhotosList: Codable {
    var pages: Int
    var total: Int
    var photo: [Photos]
    
    enum CodingKeys: String, CodingKey {
        case pages
        case total
        case photo
    }
}

struct FlickrPhotosSearchResponse: Codable {
    var photos: PhotosList
    
    enum CodingKeys: String, CodingKey {
        case photos
    }
}
