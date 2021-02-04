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
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUoViewHighConstrains: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus() //keep tracking our authorization status
    let regionRedius: Double = 1000 // region is 1000 meter large
    
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        configureLocetionServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell") //PhotCell.self let us use as a class object
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDwon))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        // modife constraians to move up view
        pullUoViewHighConstrains.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded() // update constraints and layout if needed is going to redraw what was changed
        }
    }
    
    @objc func animateViewDwon() {
        cancelAllSession()
        pullUoViewHighConstrains.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - (spinner!.frame.width / 2), y: 150)
        spinner?.style = .large
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        
        collectionView?.addSubview(spinner!) // we can unwrap becous it was properly instantiate
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        
        collectionView?.addSubview(progressLbl!) // we add it in collection view not on pulUpView becous we dont want tjat collection view cover progressLbl and spinner
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil // not upadte a pin in current location
        }
        // customize our pin
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRedius * 2.0, longitudinalMeters: regionRedius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSession() // remove old session
        
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData() // we dont want see previous pictures
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
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
        
        retriveUrls(forAnnotation: annotation) { (success) in
            if success {
                self.retrieveImages { (finish) in
                    if finish {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
        
    }
    
    func removePin() {
        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }
    }
    
    func retriveUrls(forAnnotation annotaion: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        
        AF.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotaion, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.value as? Dictionary<String, AnyObject> else { return }// this type is response of json (response return this kind of dictionary)
            let photosDict = json["photos"] as! Dictionary<String, AnyObject> // dictionry photos has this type of dictionry inside
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray { // create url from json which include photos
                let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!).jpg" // defoult image size from flickr is 500px
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        
        // creat AF request to download images
        for url in imageUrlArray {
            AF.request(url).responseImage { (response) in // AF return UIImage and let as use that
                guard let image = response.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)_/40 IMAGES DOWNLOADED"// update progress lbl
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            }
        }
    }
    
    func cancelAllSession() {
        Session.default.cancelAllRequests(completingOnQueue: .main) {
            print("Cancelled all requests.")
        }
        
//        Session.default.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
//            sessionDataTask.forEach({ $0.cancel() })// $0 is like for task in sessionDatatask { print(taks) || task.cancel}-- signle line for loop
//            downloadData.forEach({ $0.cancel() })
//        }
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // number of items in array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imagefromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imagefromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    
}
