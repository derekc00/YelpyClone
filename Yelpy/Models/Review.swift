//
//  Review.swift
//  Yelpy
//
//  Created by Derek Chang on 8/2/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import Foundation
import UIKit

struct Review {
    var rating: Int?
    var user: User
    var text: String?
    var timeCreated: String?
    
    init(dict: [String:Any]) {
        rating = dict["rating"] as? Int
        user = User.init(dict: dict["user"] as! [String:Any])
        text = dict["text"] as? String
        timeCreated = dict["time_created"] as? String
        
    }
}

struct User {
    var id: String?
    var profileUrl: URL?
    var imageUrl: URL?
    var name: String?
    var pUrl: URL?
    init(dict: [String:Any]){
        id = dict["id"] as? String
        
        if let urlString = dict["profile_url"] as? String{
            if urlString.count > 0{
                imageUrl = URL(string: urlString)
            }
        }else{
            print("Error: Profile URL on \(String(describing: name))")
        }
        if let urlString = dict["image_url"] as? String{
            if urlString.count > 0{
                imageUrl = URL(string: urlString)
            }
            
        }else{
            print("Error: Image URL on \(String(describing: name))")
        }
        
        name = dict["name"] as? String
        
    }
}
