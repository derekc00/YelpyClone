//
//  DetailsViewController.swift
//  Yelpy
//
//  Created by Derek Chang on 7/23/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AudioToolbox
import MapKit
import SkeletonView
import CoreLocation
import MessageUI

class DetailsViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewImage: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var isClosedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var expectedTravelLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var callLabel: UILabel!
    
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var callView: UIView!
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var phoneImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var locationManager: CLLocationManager?
    
    var restuarant: Restaurant?
    
    var destination: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        scrollView.delegate = self

        self.initScrollView()
        
        self.startSkeleton()
        
        self.addTapGestures()
        
        self.fillLabels()
        
        addBottomBorder(view: directionView, thickness: 1.0, margin: 24, bgColor: #colorLiteral(red: 0.9247964454, green: 0.9247964454, blue: 0.9247964454, alpha: 1))
        
        API.getReviews(id: restuarant!.id) { (success) in
            
            self.initMapView()

        }
    }
    //test
    //allows views inside scroll view to respond to both scrolling and tap gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func initMapView() {
        mapView.showsUserLocation = true
        
        let currentLocation: CLLocationCoordinate2D = (locationManager?.location!.coordinate)!
        self.destination = CLLocationCoordinate2D(latitude: (restuarant?.coordinates["latitude"])!, longitude: (restuarant?.coordinates["longitude"])!)
        
        addPin(title: "", latitude: self.destination!.latitude, longitude: self.destination!.longitude)
        
        displayRoutes(source: currentLocation, destination: self.destination!)
        
    }

    //Requests directions and adds its to mapview
    func displayRoutes(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D){
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { ( response, error) in
            guard let unwrappedResponse = response else {return}
            
            //MUST STOP SKELETON BEFORE FILLING LABELS/IMAGES
            self.stopSkeleton()
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: false)
                
                self.distanceLabel.text = String(round(route.distance * 10 * 0.000621371) / 10) + " mi"
                self.expectedTravelLabel.text = String(Int(round(route.expectedTravelTime / 60)) + 1) + " min drive"
            }
            
            
            
        }
    }
    func startSkeleton(){
        [distanceLabel, addressLabel, expectedTravelLabel, phoneLabel, callLabel, mapView, carImage, phoneImage ].forEach {
                $0?.isSkeletonable = true
                $0?.showAnimatedGradientSkeleton()
        }
    }
    func stopSkeleton(){
        
        [distanceLabel, addressLabel, expectedTravelLabel, phoneLabel, callLabel,  mapView, carImage, phoneImage ].forEach {
        $0?.hideSkeleton()
        }
    }
    
    //customize directions overlay (ie blue line that shows direction)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0.1554663881, green: 0.6363340603, blue: 0.9606393373, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func addPin(title: String, latitude: Double, longitude: Double) {
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = locationCoordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    
    
    //Fills all the labels after a segue is completed to this VC
    private func fillLabels() {
        if let imageUrl = restuarant?.imageURL {
            mainImage.af.setImage(withURL: imageUrl)
            let gradient = CAGradientLayer()
                            
            gradient.frame = mainImage.bounds
    //        insert black shadow from bottom and top of main image to emphasize restaurant name and navigation commands
            gradient.colors = [ UIColor(white: 0.2, alpha: 0.1).cgColor , UIColor(white: 0.1, alpha: 0.05).cgColor, UIColor(white: 0.1
                , alpha: 0.3).cgColor ]
            gradient.locations = [0.0, 0.5, 0.9]
            mainImage.layer.insertSublayer(gradient, at: 0)
        }
        if let name = restuarant?.name {
            nameLabel.text = name
            nameLabel.font = UIFont.appBlackFontWith(size: 32)
        }
        if let reviews = restuarant?.stars {
            reviewImage.image = reviews
        }
        if let reviewCount = restuarant?.reviews {
            reviewCountLabel.text = String(reviewCount)
            reviewCountLabel.font = UIFont.appLightFontWith(size: 12)
        }
        if let isClosed = restuarant?.isClosed {
            if isClosed == 0 {
                isClosedLabel.text = "Open"
                isClosedLabel.textColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1.0)
            } else{
                isClosedLabel.text = "Closed now"
                isClosedLabel.textColor = UIColor(red: 210/255, green: 31/255, blue: 60/255, alpha: 1.0)
            }
            isClosedLabel.font = UIFont.appBoldFontWith(size: 14)
        }
        
        if let address = restuarant?.address {
            addressLabel.text = address
        }
        if let phoneNumber = restuarant?.displayPhone {
            phoneLabel.text = phoneNumber
        }
        
    }
    
    //uses the restaurant's phone number to prompt a call
    @objc func call(gesture: UITapGestureRecognizer){
        
        
        //change bgColor and send vibration
        if gesture.state == .began {
            callView.backgroundColor = #colorLiteral(red: 0.9247964454, green: 0.9247964454, blue: 0.9247964454, alpha: 1)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        //Upon release, reset bg color & present call prompt
        if gesture.state == .ended {
            callView.backgroundColor = UIColor.clear
            
            //No action if gesture moved off view
            let touchLocation = gesture.location(in: gesture.view)
            if !directionView.bounds.contains(touchLocation){
                print("Gesture moved off callView")
                return
            }
            
            if let number = restuarant?.phoneNumber {
                let formattedNumber = String(number.dropFirst(2))
                callNumber(phoneNumber: formattedNumber)
            }
        }
        
        
    }
    //prompts a call to the restaurant
    private func callNumber(phoneNumber:String) {

        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)
                }
            }
        }
    }
    
    private func addBottomBorder(view: UIView, thickness: CGFloat, margin: CGFloat, bgColor: CGColor) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: margin, y: view.frame.size.height - thickness, width: view.frame.size.width - 2*margin, height: thickness)
        bottomBorder.backgroundColor = bgColor
        
        view.layer.addSublayer(bottomBorder)
    }
    
    @objc func getDirections(gesture : UITapGestureRecognizer){
        
        
        //change bgColor and send vibration
        if gesture.state == .began {
            directionView.backgroundColor = #colorLiteral(red: 0.9247964454, green: 0.9247964454, blue: 0.9247964454, alpha: 1)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        if gesture.state == .cancelled || gesture.state == .failed{
            directionView.backgroundColor = UIColor.clear
            return
        }
        //Upon release, reset bg color & open Maps with directions to restaurant
        if gesture.state == .ended {
            directionView.backgroundColor = UIColor.clear

            //No action if gesture moved off view
            let touchLocation = gesture.location(in: gesture.view)
            if !directionView.bounds.contains(touchLocation){
                print("Gesture moved off directionView")
                return
            }
            
            let dest: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.destination!))
            dest.name = nameLabel.text
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            dest.openInMaps(launchOptions: launchOptions)
        }
    }
    
    
    
    //handles share with Text button
    @IBAction func shareWithText(_ sender: Any) {
        let messageVC = MFMessageComposeViewController()
            
        messageVC.body = restuarant?.url?.absoluteString
        messageVC.messageComposeDelegate = self
            
        self.present(messageVC, animated: true, completion: nil)
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("user cancelled text msg")
            break
        case .sent:
            print("successful text msg")
            break
        case .failed:
            print("failed text msg")
            break
        default:
            return
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    //handles share button
    @IBAction func shareWithOptions(_ sender: Any){
        
        if let url = restuarant?.url {
            let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: [])
        
            present(shareVC, animated: true, completion: nil)
        }
    }
    
    private func initScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    private func addTapGestures(){
        //add action to call button
        let tapCallButton = UILongPressGestureRecognizer(target: self, action: #selector(call))
        tapCallButton.minimumPressDuration = 0.05
        
        callView.addGestureRecognizer(tapCallButton)
        
        
        let tapMapButton = UILongPressGestureRecognizer(target: self, action: #selector(getDirections))
        tapMapButton.minimumPressDuration = 0.05
        tapMapButton.delegate = self
        tapMapButton.cancelsTouchesInView = false
        directionView.addGestureRecognizer(tapMapButton)
    }
}

