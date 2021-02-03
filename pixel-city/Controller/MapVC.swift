//
//  MapVC.swift
//  pixel-city
//
//  Created by Artur Zarzecki on 02/02/2021.
//  Copyright © 2021 Artur Zarzecki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus() //keep tracking our authorization status
    let regionRedius: Double = 1000 // region is 1000 meter large

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        configureLocetionServices()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRedius * 2.0, longitudinalMeters: regionRedius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        // drop the pin on the map
        //creat touch point
        let touchPoint = sender.location(in: mapView) // give cordinate of the screen
        // convert to gps coordinate
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, indentifire: "droppablePin")
        mapView.addAnnotation(annotation) // will show on the map view
        
        //center pin
        let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRedius * 2.0, longitudinalMeters: regionRedius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func removePin() {
        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocetionServices() {
        //check if we are authorize to use our curent location
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            //if we are already approved or deneid there is no need to do any hangouts
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { // is called evry time the map is calling authorization
        centerMapOnUserLocation()
    }
}
