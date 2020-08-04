//
//  RestaurantCell.swift
//  Yelpy
//
//  Created by Derek Chang on 7/15/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireImage 

class RestaurantCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var isClosed: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var reviewCount: UILabel!
    
    var phone: String!
    
    
    var locationManager: CLLocationManager?
    
    var r: Restaurant! {
        didSet {
            
            name.text = r.name
            name.font = UIFont.appBoldFontWith(size: 14)
            category.text = r.categories.joined(separator: ", ")
            category.font = UIFont.appRegularFontWith(size: 12)
            phone = r.displayPhone
            reviewCount.text = String(r.reviews) + " Reviews"
            reviewCount.font = UIFont.appRegularFontWith(size: 12)
            price.text = r.price
            price.font = UIFont.appRegularFontWith(size: 12)
            address.text = r.shortAddress
            address.font = UIFont.appLightFontWith(size: 12)
            
//            if r.isClosed == 1{
//                isClosed.text = "Closed now"
//            } else{
//                isClosed.text = "Open now"
//            }
            
            
            //set images
            ratingImage.image = r.stars
            
            if let imageURL = r.imageURL {
                restaurantImage.af.setImage(withURL: imageURL)
                restaurantImage.layer.cornerRadius = 10
                restaurantImage.clipsToBounds = true
            }
            
            //set distance label
            distance.text = getDistance(coordinates: r.coordinates)
            distance.font = UIFont.appLightFontWith(size: 12)
        }
    }
    
    //Returns distnance from user to the coords of a restuarant
    //if no user location is present, default is San Francisco coords. See Restaurant.swift for constructor of "coordinates" property
    func getDistance(coordinates: [String:Double]) -> String{
        //extract lat and long
        let restaurantCoords = CLLocation(latitude: coordinates["latitude"]!, longitude: coordinates["longitude"]!)
        //declare var to store distance between two coordinates (me and the restaurant)
        var distance_from_current_location: Measurement<UnitLength>
        //Check to see if locationManager has a location. This will be nil if user decline to share location
        if let current_location = locationManager?.location {
            distance_from_current_location = Measurement(value: current_location.distance(from: restaurantCoords), unit: UnitLength.meters)
        } else{ //if declined to share location, use hardcode San Francisco coordinates
            distance_from_current_location = Measurement(value: CLLocation(latitude: 37.773972, longitude: -122.431297).distance(from: restaurantCoords), unit: UnitLength.meters)
        }
        //convert meters to miles and truncate to 1 decimal place
        return String(format: "%.1f",distance_from_current_location.converted(to: UnitLength.miles).value) + " mi"

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIFont {
    class func appLightFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Roboto-Light", size: size)!
    }
    class func appRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Roboto-Regular", size: size)!
    }
    class func appBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Roboto-Bold", size: size)!
    }
    class func appBlackFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Roboto-Black", size: size)!
    }
}
