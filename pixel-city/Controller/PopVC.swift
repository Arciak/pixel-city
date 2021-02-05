//
//  PopVC.swift
//  pixel-city
//
//  Created by Artur Zarzecki on 04/02/2021.
//  Copyright © 2021 Artur Zarzecki. All rights reserved.
//

import UIKit
import MapKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var mapViewSmall: MKMapView!
    
    var passedImage: UIImage!
    var titleText: String!
    var coordinate: CLLocationCoordinate2D!
    
    func initData(forImage image: UIImage, photoTitle title: String, photoCoordination coordinate: CLLocationCoordinate2D) {
        self.passedImage = image
        self.titleText = title
        self.coordinate = coordinate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        titleLbl.text = titleText
        initMapView(coordinate: coordinate)
        addDoubleTap()
    }
    
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    func initMapView(coordinate: CLLocationCoordinate2D) {
        let annotation = DroppablePin(coordinate: coordinate, indentifire: "droppablePin")
        mapViewSmall.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 1000.0 * 0.5, longitudinalMeters: 1000.0 * 0.5)
        mapViewSmall.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }

}
