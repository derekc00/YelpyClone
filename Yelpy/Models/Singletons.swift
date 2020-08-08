//
//  Singletons.swift
//  Yelpy
//
//  Created by Derek Chang on 8/7/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//singleton: all VC's can access restaurant array
class Restaurants {
    static let sharedInstance = Restaurants()
    var array = [Restaurant]()
}
