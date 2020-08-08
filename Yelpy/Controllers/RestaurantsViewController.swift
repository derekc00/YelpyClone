//
//  ViewController.swift
//  Yelpy
//
//  Created by Derek on 7/15/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//  Design inspired by Wen Tong.
//

import UIKit
import CoreLocation
import SkeletonView
 
class RestaurantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
//    var restaurantsArray: [Restaurant] = []
    
    let locationManager = CLLocationManager()
    
    private var shouldAnimate = true
    private var searchRestaurants = [Restaurant]()
    var searching: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 330
        
        searchBar.backgroundImage = UIImage()
        
        locationManager.delegate = self

        //populates restaurantsArray and reloads Data inside tableview
        getAPIData()
    }
    //must begin skeleton animation in here to avoid compile warning
    override func viewDidLayoutSubviews() {
        
        if !shouldAnimate {return}
        shouldAnimate = false
        tableView.showAnimatedGradientSkeleton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        
    }
    
    //Get data from API helper and retrieve restaurants
    func getAPIData() {
        
        let curLocation = getCurrentLocation(locationManager: locationManager)
        
        API.getRestaurants(lat: curLocation.lat,long: curLocation.long) { (restaurants) in
            guard let restaurants = restaurants else{
                self.getAPIData() //call API again if failed to return restaurants
                return
            }
            Restaurants.sharedInstance.array = restaurants
            self.shouldAnimate = false
            self.tableView.hideSkeleton()
            self.tableView.reloadData()
            
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return self.searchRestaurants.count
        }
        return  Restaurants.sharedInstance.array.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        
        var restaurant: Restaurant!
        if searching {
            restaurant = searchRestaurants[indexPath.row]
        } else{
            restaurant = Restaurants.sharedInstance.array[indexPath.row]
        }
        
        
        if self.shouldAnimate {
            cell.showAnimatedGradientSkeleton()
        } else{
            cell.hideSkeleton()
        }
        //must set locationManager of cell to determine distance from user
        cell.locationManager = locationManager
        
        cell.r = restaurant
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //get the index of the cell that was pressed/passed through sender parameter
        guard let indexPath = tableView.indexPathForSelectedRow else{
            return
        }
        
        if segue.identifier == "detailSegue"{
            var restaurant: Restaurant!
            if searching{ restaurant = searchRestaurants[indexPath.row]}
            else {restaurant = Restaurants.sharedInstance.array[indexPath.row]}
            
            let detailViewController = segue.destination as! DetailsViewController
            detailViewController.restuarant = restaurant
            detailViewController.locationManager = locationManager
        }
        
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //Uses CLLocationManager to ask the user for their location
    //If they decline, return hardcoded san francisco coordinates
    func getCurrentLocation(locationManager: CLLocationManager)-> ( lat: Double, long:Double) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            if let currentLocation = locationManager.location {
                print("successfully received current location")
                return (currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            }
        case .denied:
            print("user denied location services. Attempting reprompt")
            locationManager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            print("user location services not determined. Attempting reprompt")
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
        
        // If fail to get current location or denied location tracking, return coordinates for San Francisco
        return (Double(37.773972), Double(-122.431297))
    }

    //this is called when the user performs an action on the location request prompt
    //Check to see what the new state is, If they allowed us to track their location, get new data(restaurants)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                break
            default:
                getAPIData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRestaurants = Restaurants.sharedInstance.array.filter({$0.name.lowercased().contains(searchText.lowercased())})
        print(searchRestaurants.count)
        searching = true
        
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.endEditing(true)
        searchBar.text = ""
        tableView.reloadData()
    }
}
extension RestaurantsViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "RestaurantCell"
    }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
}


