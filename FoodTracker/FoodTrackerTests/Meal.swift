//
//  Meal.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/15/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class Meal {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int) {
        
        self.name = name
        self.photo = photo
        self.rating = rating
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            
            // Because the initializer now might return nil, you need to indicate this in the initializer signature.
            return nil
        }
    
    }
    
    
    
}
