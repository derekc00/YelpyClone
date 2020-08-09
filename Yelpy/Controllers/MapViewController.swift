//
//  MapViewController.swift
//  Yelpy
//
//  Created by Derek Chang on 8/7/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backToCurrentButton: UIButton!
    @IBOutlet weak var redoSearchButton: UIButton!
    var locationManager: CLLocationManager!
    
    var loadedMap: Bool = false
    var mapUpdateCount: Int = 0
    var shouldShowRedo: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        
        // Do any additional setup after loading the view.
        mapView.showsUserLocation = true
        
        redoSearchButton.layer.cornerRadius = 3
        redoSearchButton.alpha = 0.0
        
        backToCurrentButton.layer.cornerRadius = backToCurrentButton.bounds.width / 2
        backToCurrentButton.setImage(UIImage(systemName: "location"), for: UIControl.State.normal)
        backToCurrentButton.setImage(UIImage(systemName : "location.fill"), for: UIControl.State.selected)
        
        backToCurrentButton.isSelected = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initMapView()
    }
    // --------------------Map View Functions-------------------------------------------------------------------
    private func initMapView() {
        
        Restaurants.sharedInstance.array.forEach { (restaurant) in
            let name = restaurant.name
            guard let lat: Double = restaurant.coordinates["latitude"] else{
                print("unable to retrieve lat in shared restaurant array in mapVC")
                return
            }
            guard let long: Double = restaurant.coordinates["longitude"] else {
                print("unable to retrieve long in shared restaurant array in mapVC")
                return
            }
            
            addPin(title: name, latitude: lat, longitude: long)
        }

    }

    func showRedo(){
        
        UIView.animate(withDuration: 0.8, animations: {
            self.redoSearchButton.alpha = 1.0
        })
    }
    func hideRedo(){
        UIView.animate(withDuration: 0.6, animations: {
                   self.redoSearchButton.alpha = 0.0
        })
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if mapUpdateCount < 1{
            mapUpdateCount+=1
            return
        }
        showRedo()
        backToCurrentButton.isSelected = false
        print(backToCurrentButton.isSelected)
    }
    @IBAction func backToCurrentLocation(_ sender: Any) {
        print(backToCurrentButton.isSelected)
        if backToCurrentButton.isSelected == true {
            backToCurrentButton.isSelected = false
        } else {
            UIView.animate(withDuration: 1.3) {
                self.mapView.centerCoordinate = self.mapView.userLocation.coordinate
            }
            backToCurrentButton.isSelected = true
        }
    }
    
    //Get data from API helper and retrieve restaurants
    @IBAction func getAPIData() {
        
        API.getRestaurants(lat: mapView.centerCoordinate.latitude,long: mapView.centerCoordinate.longitude) { (restaurants) in
            guard let restaurants = restaurants else{
                self.getAPIData() //call API again if failed to return restaurants
                return
            }
//            print(Restaurants.sharedInstance.array.count)
            Restaurants.sharedInstance.array.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
//            print(Restaurants.sharedInstance.array.count)
            Restaurants.sharedInstance.array = restaurants
//            print(Restaurants.sharedInstance.array.count)
            self.initMapView()
            
            self.hideRedo()
            
        }
        
    }
    
    //once the map is loaded, the user location will be available through the mapView instance
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("aaaa")
        if loadedMap { return}
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        print(userLocation.coordinate)
        mapView.setRegion(region, animated: false)
        loadedMap = true
    }
    //customize directions overlay (ie blue line that shows direction)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0.1554663881, green: 0.6363340603, blue: 0.9606393373, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
    
    //makes all annotations visible regardless of zooming in/out
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else{return nil}
        
        let reuseIdentifier = "annotationView"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if #available(iOS 11.0, *) {
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            view?.displayPriority = .required
        } else {
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
        }
        view?.annotation = annotation
        view?.canShowCallout = true
        return view
    }
    
    func addPin(title: String, latitude: Double, longitude: Double) {
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = locationCoordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    

}
