//
//  DroppablePin.swift
//  pixel-city
//
//  Created by Artur Zarzecki on 03/02/2021.
//  Copyright © 2021 Artur Zarzecki. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D // are able to be modifed the way we need to in MKAnnotaiotion
    var indentifire: String
    
    init( coordinate: CLLocationCoordinate2D, indentifire: String ) {
        self.coordinate = coordinate
        self.indentifire = indentifire
        super.init() // allow us to use it as initializer as a custom pin
    }
    
}
