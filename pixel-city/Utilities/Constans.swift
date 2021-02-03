//
//  Constans.swift
//  pixel-city
//
//  Created by Artur Zarzecki on 03/02/2021.
//  Copyright © 2021 Artur Zarzecki. All rights reserved.
//

import Foundation

let apiKey = "4261abe3b4069efd2506516da91d32c3"

func flickrUrl(forApiKey: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}
