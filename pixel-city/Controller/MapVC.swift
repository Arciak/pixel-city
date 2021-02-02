//
//  MapVC.swift
//  pixel-city
//
//  Created by Artur Zarzecki on 02/02/2021.
//  Copyright © 2021 Artur Zarzecki. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    
}

extension MapVC: MKMapViewDelegate {
    
}

