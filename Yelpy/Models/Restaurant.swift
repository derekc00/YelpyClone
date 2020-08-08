//
//  Restaurant.swift
//  Yelpy
//
//  Created by Derek Chang on 7/23/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import Foundation
import UIKit



class Restaurant {
    var imageURL: URL?
    var url: URL?
    var name: String
    var categories: [String]
    var displayPhone: String
    var rating: Double
    var reviews: Int
    var stars: UIImage
    var isClosed: Int
    var price: String
    var coordinates: [String:Double]
    var address: String
    var shortAddress: String
    var phoneNumber: String
    var id: String
    
    init(dict:[String:Any]) {
        imageURL = URL(string: dict["image_url"] as! String) ?? nil
        name = dict["name"] as? String ?? ""
        rating = dict["rating"] as! Double
        reviews = dict["review_count"] as! Int
        displayPhone = dict["display_phone"] as! String
        url = URL(string: dict["url"] as! String)
        categories = Restaurant.getCategories(dict: dict)
        stars = UIImage(named: Restaurant.getFormatedRating(rating: dict["rating"] as! Double)) ?? UIImage(named: "regular_0")!
        isClosed = dict["is_closed"] as? Int ?? 1
        price = dict["price"] as? String ?? "$"
        coordinates = dict["coordinates"] as? [String:Double] ?? ["latitude":37.773972, "longitude":-122.431297]
        address = Restaurant.getAddress(dict: dict)
        shortAddress = Restaurant.getShortAddress(dict: dict)
        phoneNumber = dict["phone"] as? String ?? ""
        id = dict["id"] as? String ?? ""
    }
    
    /*
     Static Functions are invoked by the class itself, not by an instance
     */
    
    //returns the first category in category object containing mult categories
    //expected output: [Bakeries, Sandwiches, Cafes]
    static func getCategories(dict: [String:Any]) -> [String] {
        let categories = dict["categories"] as! [[String:Any]]
        var result: [String] = []
        for category in categories{
            if let title = category["title"] as? String{
                result.append(title)
            }
        }
        return result
        
    }
    
    //Received a Float rating (ie. 3.5) in multiples of 0.5 and returns proper string that matches name of rating assets from yelp
    static func getFormatedRating(rating: Double) -> String{
        var result = "regular_"
        if rating.truncatingRemainder(dividingBy: 1.0) == 0 {
            result += String(Int(rating))
            return result
        } else {
            result += String(Int(rating)) + "_half"
            return result
        }
    }
    
    //Parse address from json dictionary
    static func getAddress(dict: [String:Any]) -> String {
        let location = dict["location"] as! [String:Any]
        
        let address1 = location["address1"] as! String
        let city = location["city"] as! String
        let state = location["state"] as! String
        let zipcode = location["zip_code"] as! String
        
        return address1 + ", " + city + ", " + state + " " + zipcode
    }
    
    static func getShortAddress(dict: [String:Any]) -> String {
        let location = dict["location"] as! [String:Any]
        
        let address1 = location["address1"] as! String
        let city = location["city"] as! String


        return address1 + ", " + city
    }
}


