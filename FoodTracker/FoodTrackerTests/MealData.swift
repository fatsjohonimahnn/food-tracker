//
//  MealData.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/15/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

// we would want a separate class for BE meals being saved without persisting data

class MealData: NSObject, NSCoding {
    
    // MARK: Common Properties Shared by Archiver and Backendless
    
    var name: String
    var rating: Int
    
    // MARK: Archiver Only Properties
    
    var photo: UIImage?
    
    // MARK: Backendless Only Properties
    
    var objectId: String?
    var photoUrl: String?
    var thumbnailUrl: String?
    
    // used as a book marking place in BackendlessManager
    var replacePhoto: Bool = false
    
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    // MARK: Types
    
    struct PropertyKey {
        
        // static keyword indicates that this constant applies to the structure itself, not an instance of the structure. These values will never change.
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
    }
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int) {
        
        self.name = name
        self.photo = photo
        self.rating = rating
        
        // optional bc NSObject has very generic init
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            
            // Because the initializer now might return nil, you need to indicate this in the initializer signature.
            return nil
        }
    
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        
        //method encodes any type of object
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
        
        // method encodes an integer
        aCoder.encode(rating, forKey: PropertyKey.ratingKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of MealData, use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.ratingKey)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)
    }

    
    
}
