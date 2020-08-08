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
    
    var locationManager: CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        
        // Do any additional setup after loading the view.
        mapView.showsUserLocation = true
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
    
    //once the map is loaded, the user location will be available through the mapView instance
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        print(userLocation.coordinate)
        mapView.setRegion(region, animated: false)
    }
    //customize directions overlay (ie blue line that shows direction)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0.1554663881, green: 0.6363340603, blue: 0.9606393373, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
