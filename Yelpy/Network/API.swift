//
//  File.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation



struct API {

    
    static func getRestaurants(lat: Double, long: Double, completion: @escaping ([Restaurant]?) -> Void) {
        
        let apikey = "TKCbcIFQSXJ6pTmQdpdx3VNd87bejsGlfCd9kAwoeinTYeEeqGY87AeYXIY7mQ0OGIZShuIwLqis0jEaWySSQ0EtPIgmcS-Fja1kxHLzYQYpnOPTS4Irk4c-amkPX3Yx"
        
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(lat)&longitude=\(long)&radius=20000")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                
                //Convert json response to a dictionary (hashmap)
                //json has two keys(responses,total)
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                //Grab the businesses data and convert it to an array of dictionaries for each restaurant
                let restaurantDicts = dataDictionary["businesses"] as! [[String:Any]]
                
                var restaurants:[Restaurant] = []
                
                //data representation:
                    //list of restaurants (ie. R0, R1, R2...)
                                            // k/v pairs for each restaurant
                for dictionary in restaurantDicts{
                    //pass in each dictionary to constructor of Restaurants
                    let restaurant = Restaurant.init(dict: dictionary)
                    restaurants.append(restaurant)
                }
                
                //Completion is an escaping method which allows the data to be used outside of the closure
                return completion(restaurants)
                }
            }
        
            task.resume()
        
        }
    
    static func getReviews(id: String, completion: @escaping ([Any]?) -> Void) {
        
        let apikey = "TKCbcIFQSXJ6pTmQdpdx3VNd87bejsGlfCd9kAwoeinTYeEeqGY87AeYXIY7mQ0OGIZShuIwLqis0jEaWySSQ0EtPIgmcS-Fja1kxHLzYQYpnOPTS4Irk4c-amkPX3Yx"
        
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(id)/reviews")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                
                //Convert json response to a dictionary (hashmap)
                //json has two keys(responses,total)
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                //Grab the businesses data and convert it to an array of dictionaries for each restaurant
                let reviewDictionary = dataDictionary["reviews"] as! [[String:Any]]
                
                var reviews:[Review] = []
                
                //data representation:
                    //list of restaurants (ie. R0, R1, R2...)
                                            // k/v pairs for each restaurant
                for dictionary in reviewDictionary{
                    //pass in each dictionary to constructor of Restaurants
                    let review = Review.init(dict: dictionary)
                    reviews.append(review)
                }
                
                //Completion is an escaping method which allows the data to be used outside of the closure
                return completion(reviews)
                }
            }
        
            task.resume()
        
        }
    }

    
