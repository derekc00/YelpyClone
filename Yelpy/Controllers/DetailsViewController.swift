//
//  DetailsViewController.swift
//  Yelpy
//
//  Created by Derek Chang on 7/23/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//
//Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
//Icons made by <a href="https://www.flaticon.com/authors/pixel-perfect" title="Pixel perfect">Pixel perfect</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var copyLinkView: UIView!
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var phoneImage: UIImageView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var locationManager: CLLocationManager?
    
    var restuarant: Restaurant?
    
    var destination: CLLocationCoordinate2D?
    
    var statusBarFrame: CGRect!
    var statusBarView: UIView!
    var offset: CGFloat!
    var isAnimating: Bool! = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        scrollView.delegate = self

        //header view begins overlapped to the naviagation bar
        scrollView.contentInsetAdjustmentBehavior = .never
        
        self.setupStatusBar()
        self.fillLabels()
        
        self.startSkeleton()
        
        self.addTapGestures()
        
        
        addBottomBorder(view: directionView, thickness: 1.0, margin: 24, bgColor: #colorLiteral(red: 0.9247964454, green: 0.9247964454, blue: 0.9247964454, alpha: 1))
        addRightBorder(view: messagesView, thickness: 1.0, margin: 4, bgColor: #colorLiteral(red: 0.9247964454, green: 0.9247964454, blue: 0.9247964454, alpha: 1))
        API.getReviews(id: restuarant!.id) { (success) in
            
            self.initMapView()

        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //format navigation bar for detail screen
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //show restaurant name when the nav bar is white
        self.navigationItem.title = restuarant?.name
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.clear]

        
        CATransaction.flush()
    }
    //reset navigation bar to clear upon leaving the VC
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("a")
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
    }
    
    private func setupStatusBar(){
        //get height of status bar
        if #available(iOS 13.0, *) {
            statusBarFrame = UIApplication.shared.windows[0].windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            // Fallback on earlier versions
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        //set status bar with white text
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black

        //add a view on top of the status bar
        statusBarView = UIView(frame: statusBarFrame)
        statusBarView.isOpaque = false
        statusBarView.backgroundColor = .clear
        view.addSubview(statusBarView)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Mark the end of the offset
        guard let navBarHeight = self.navigationController?.navigationBar.bounds.height else{return}
        let targetHeight = headerView.bounds.height - navBarHeight - statusBarFrame.height
        
        //calculate how much has been scrolled relative to the targetHeight
        offset = scrollView.contentOffset.y / targetHeight
                
        //cap offset to 1 to conform to UIColor alpha parameter
        if offset > 1 {offset = 1}
        
        if offset > 0.5 {
            self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        } else {
            self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        }
        
        //the restuarant title fades in when the offset is at 80%
        if offset > 0.8 {
            //map black color's alpha to the remaining 20% to 0.0-1.0
            let clearToBlack = UIColor(red: 0, green: 0, blue: 0, alpha: (offset - 0.8)*5)
            print(clearToBlack)
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: clearToBlack]
        } else{
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        }
        
        let clearToWhite = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
        let whiteToBlack = UIColor(hue: 1, saturation: 0, brightness: 1-offset, alpha: 1 )
        self.navigationController?.navigationBar.tintColor = whiteToBlack
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = whiteToBlack
        
        //change and sync navigation controller and status bar bg color
        self.navigationController?.navigationBar.backgroundColor = clearToWhite
        statusBarView!.backgroundColor = clearToWhite
        
    }
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
    func fillLabels() {
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
            addressLabel.font = UIFont.appLightFontWith(size: 12)
        }
        if let phoneNumber = restuarant?.displayPhone {
            phoneLabel.text = String(phoneNumber)
            phoneLabel.font = UIFont.appLightFontWith(size: 12)
            print(phoneLabel.text)
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
    
    @objc func message(gesture: UITapGestureRecognizer){
        print("a")
        //change bgColor and send vibration
        if gesture.state == .began {
            messagesView.backgroundColor = #colorLiteral(red: 0.9247964454, green: 0.9247964454, blue: 0.9247964454, alpha: 1)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        
        //Upon release, reset bg color & present call prompt
        if gesture.state == .ended {
            messagesView.backgroundColor = UIColor.clear
            
            //No action if gesture moved off view
            let touchLocation = gesture.location(in: gesture.view)
            if !messagesView.bounds.contains(touchLocation){
                print("Gesture moved off callView")
                return
            }
            
            let messageVC = MFMessageComposeViewController()
                
            messageVC.body = restuarant?.url?.absoluteString
            messageVC.messageComposeDelegate = self
                
            self.present(messageVC, animated: true, completion: nil)
            
        }
    }
    private func addBottomBorder(view: UIView, thickness: CGFloat, margin: CGFloat, bgColor: CGColor) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: margin, y: view.frame.size.height - thickness, width: view.frame.size.width - 2*margin, height: thickness)
        bottomBorder.backgroundColor = bgColor
        
        view.layer.addSublayer(bottomBorder)
    }
    private func addRightBorder(view: UIView, thickness: CGFloat, margin: CGFloat, bgColor: CGColor) {
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: view.frame.size.width - thickness, y: margin, width: thickness, height: view.frame.size.height - 2*margin)
        rightBorder.backgroundColor = bgColor
        
        view.layer.addSublayer(rightBorder)
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
    private func addTapGestures(){
        //add action to call button
        let tapCallButton = UILongPressGestureRecognizer(target: self, action: #selector(call))
        tapCallButton.minimumPressDuration = 0.1
        tapCallButton.delegate = self
        tapCallButton.cancelsTouchesInView = false
        callView.addGestureRecognizer(tapCallButton)
        
        
        let tapMapButton = UILongPressGestureRecognizer(target: self, action: #selector(getDirections))
        tapMapButton.minimumPressDuration = 0.1
        tapMapButton.delegate = self
        tapMapButton.cancelsTouchesInView = false
        directionView.addGestureRecognizer(tapMapButton)
        
        let tapMessages = UILongPressGestureRecognizer(target: self, action: #selector(message))
        tapMessages.minimumPressDuration = 0.1
        tapMessages.delegate = self
        tapMessages.cancelsTouchesInView = false
        messagesView.addGestureRecognizer(tapMessages)
    }

}
