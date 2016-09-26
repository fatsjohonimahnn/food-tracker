//
//  BackendlessManager.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/22/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import Foundation


// The BackendlessManager class below is using the Singleton pattern.
// A singleton class is a class which can be instantiated only once.
// In other words, only one instance of this class can ever exist.
// The benefit of a Singleton is that its state and functionality are
// easily accessible to any other object in the project.

class BackendlessManager {
    
    // This gives access to the one and only instance.
    static let sharedInstance = BackendlessManager()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    let backendless = Backendless.sharedInstance()!
    
    let APP_ID = "<App-ID>"
    let SECRET_KEY = "<App-secret-key>"
    let VERSION_NUM = "v1"
    
    let EMAIL = "test@gmail.com" // Doubles as User Name
    let PASSWORD = "password"
    
    func initApp() {
        
        // First, init Backendless! called in AppDelegate
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        backendless.userService.setStayLoggedIn(true)
        
    }
    
    func isUserLoggedIn() -> Bool {
        
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            return true
        } else {
            return false
        }
    }
    
    func registerTestUser() {
        
        let user: BackendlessUser = BackendlessUser()
        user.email = EMAIL as NSString!
        user.password = PASSWORD as NSString!
        
        backendless.userService.registering( user,
                                             
            response: { (user: BackendlessUser?) -> Void in
                                                
                print("User was registered: \(user?.objectId)")
                                                
                self.loginTestUser()
            },
                                             
            error: { (fault: Fault?) -> Void in
                print("User failed to register: \(fault)")
                                                
                print(fault?.faultCode)
                                                
                // If fault is for "User already exists." - go ahead and just login!
                if fault?.faultCode == "3033" {
                    self.loginTestUser()
                }
            }
        )
    }
    
    func loginTestUser() {
        
        backendless.userService.login( self.EMAIL, password: self.PASSWORD,
                                       
            response: { (user: BackendlessUser?) -> Void in
                print("User logged in: \(user!.objectId)")
            },
                                       
            error: { (fault: Fault?) -> Void in
                print("User failed to login: \(fault)")
            }
        )
    }
    
    func logoutTestUser() {
        
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            
            // if logged in, go ahead and log them out
            
            backendless.userService.logout( { (user: Any!) -> Void in
                print("User logged out!")
                },
                    error: { (fault: Fault?) -> Void in
                        print("User failed to log out: \(fault)")
                    }
            )
        } else {
            
            // If we were unable to find a valid user token, the user is already logged out
            print("User is already logged out: \(isValidUser?.boolValue)");
        }
    }
    
    
    func saveTestData() {
        
        let newMeal = Meal()
        newMeal.name = "Test Meal #1"
        newMeal.photoUrl = "https://guildsa.org/wp-content/uploads/2016/09/meal1.png"
        newMeal.rating = 5
        
        backendless.data.save( newMeal,
                               
            response: { (entity: Any?) -> Void in
                                
                let meal = entity as! Meal
                                
                print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
            },
                               
            error: { (fault: Fault?) -> Void in
                print("Meal failed to save: \(fault)")
            }
        )
    }
    
    func loadTestData() {
        
        let dataStore = backendless.persistenceService.of(Meal.ofClass())
        
        dataStore?.find(
            
            { (meals: BackendlessCollection?) -> Void in
                
                print("Find attempt on all Meals has completed without error!")
                print("Number of Meals found = \((meals?.data.count)!)")
                
                for meal in (meals?.data)! {
                    
                    let meal = meal as! Meal
                    
                    print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                }
            },
            
            error: { (fault: Fault?) -> Void in
                print("Meals were not fetched: \(fault)")
            }
        )
    }
    
    // Adding ability to save the photo and a thumbnail of same photo 
    func savePhotoAndThumbnail(mealToSave: Meal, photo: UIImage, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        //
        // Upload the thumbnail first, bc if we cant save a small thumbnail, how can we save a large image 
        //
        
        let uuid = NSUUID().uuidString
        //print("\(uuid)")
        
        let size = photo.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.1
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        photo.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1.0);
        
        //first attempt to Upload
        backendless.fileService.upload(
            "photos/\(backendless.userService.currentUser.objectId!)/thumb_\(uuid).jpg",
            content: thumbnailData,
            overwrite: true,
            
            // response closure for success in BE
            response: { (uploadedFile: BackendlessFile?) -> Void in
                print("Thmbnail image uploaded: \(uploadedFile?.fileURL!)")
                
                mealToSave.thumbnailUrl = uploadedFile?.fileURL!
                
                //
                // Upload full size photo, if thumbnail was successful
                //
                
                let fullSizeData = UIImageJPEGRepresentation(photo, 0.2);
                
                // second attempt to upload if the first was successful
                self.backendless.fileService.upload(
                    "photos/\(self.backendless.userService.currentUser.objectId!)/full_\(uuid).jpg",
                    content: fullSizeData,
                    overwrite: true,
                    
                    // response for successful
                    response: { (uploadedFile: BackendlessFile?) -> Void in
                        print("Photo image upoad to: \(uploadedFile?.fileURL!)")
                        
                        mealToSave.photoUrl = uploadedFile?.fileURL!
                        
                        completion()
                    },
                    
                    error: { (fault: Fault?) -> Void in
                        print("Failed to save photo: \(fault)")
                        error()
                })
            },
            
            error: { (fault: Fault?) -> Void in
                print("Failed to save thumbnail: \(fault)")
                error()
        })
    }
    
    
    // MealData is the old class, made some changes
    func saveMeal(mealData: MealData, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        // save a NEW meal
        if mealData.objectId == nil {
            
            //
            // Create a new Meal along eith a photo and thumbnail image
            //
        
            let mealToSave = Meal()
            mealToSave.name = mealData.name
            mealToSave.rating = mealData.rating
            
            savePhotoAndThumbnail(mealToSave: mealToSave, photo: mealData.photo!,
                                  
                completion: {
                    
                    // Once we save the photo and its thumbnail - save the Meal!
                    self.backendless.data.save( mealToSave,
                                                
                        response: { (entity: Any?) -> Void in
                            
                            let meal = entity as! Meal
                            
                            print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                            
                            // this is where we set the meal data from TVC on the meal
                            // this stops from making duplicate records over and over again !!!!!!!!!!!!!
                            mealData.objectId = meal.objectId
                            mealData.photoUrl = meal.photoUrl
                            mealData.thumbnailUrl = meal.thumbnailUrl
                            
                            completion()
                        },
                        
                        error: { ( fault: Fault?) -> Void in
                            print("Failed to save Meal: \(fault)")
                            error()
                    })
                },
                
                error: {
                    print("Failed to save photo and thumbnail!")
                    error()
                })
            
            // are we replacing the meal data? set to true
        } else if mealData.replacePhoto {
            
            //
            // Update the Meal AND replace the existing photo and thumbnail image with new one 
            //
            
            let mealToSave = Meal()
            
            savePhotoAndThumbnail(mealToSave: mealToSave, photo: mealData.photo!,
                                  
                // if successfil in saving new images, they exist and old ones not deleted yet
                completion: {
                    
                    let dataStore = self.backendless.persistenceService.of(Meal.ofClass())
                    
                // findID user sice we know it already
                    dataStore?.findID(mealData.objectId,
                    
                        response: { (meal: Any?) -> Void in
                            
                            //We found the Meal to Update
                            let meal = meal as! Meal
                            
                            // Cache old URLs for removal!
                            let oldPhotoUrl = meal.photoUrl!
                            let oldthumbnailUrl = meal.thumbnailUrl!
                            
                            //Update the Meal with the new dataStore
                            meal.name = mealData.name
                            meal.rating = mealData.rating
                            meal.photoUrl = mealToSave.photoUrl
                            meal.thumbnailUrl = mealToSave.thumbnailUrl
                            
                            // Save the updated meal
                            self.backendless.data.save( meal,
                                                        
                                // update with new images, not old
                                response: { (entity: Any?) -> Void in
                                    
                                    let meal = entity as! Meal
                                    
                                    print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                                    
                                    // Update the mealData used by the UI with the new URLs
                                    mealData.photoUrl = meal.photoUrl
                                    mealData.thumbnailUrl = meal.thumbnailUrl
                                    
                                    // called to say we are done 
                                    completion()
                                    
                                    // Attempt to remove old photos 
                                    // if doesn't work we can always clean up later 
                                    self.removePhotoAndThumbnail(photoUrl: oldPhotoUrl, thumbnailUrl: oldthumbnailUrl, completion: {}, error: {})
                                },
                                
                                error: { (fault: Fault?) -> Void in
                                    print("Failed to save Meal: \(fault)")
                                    error()
                            })
                        },
                            
                        error: { (fault: Fault?) -> Void in
                            print("Failed to find Meal: \(fault)")
                            error()
                        }
                    )
                },
                        
                error: {
                    print("Failed to save photo and thumbnail!")
                    error()
                })
                    
            } else {
                
            //
            // Update the Meal data but keep the existing photo and thumbnail image.
            //
            
            // we could just not have this option and reupload the picture every time
            // but this drains resorces (bandwidth, battery, user's time)
            // so this is the best solution to save meal updates that don't change the picture
            
            let dataStore = backendless.persistenceService.of(Meal.ofClass())

            dataStore?.findID(mealData.objectId,
                              
                response: { (meal: Any?) -> Void in
                    
                    // We found the Meal to update.
                    let meal = meal as! Meal
                    
                    // Update the Meal with the new data
                    meal.name = mealData.name
                    meal.rating = mealData.rating
                    
                    // Save the updated Meal.
                    self.backendless.data.save( meal,
                                           
                        response: { (entity: Any?) -> Void in
                            
                            let meal = entity as! Meal
                            
                            print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                            
                            completion()
                        },
                                           
                       error: { (fault: Fault?) -> Void in
                            print("Failed to save Meal: \(fault)")
                            error()
                    })
                },
                 
                error: { (fault: Fault?) -> Void in
                    print("Failed to find Meal: \(fault)")
                    error()
                }
            )
        }
    }
    
    // completion is a closure that when called points to an array of MealData
    // job is to load and hand off to someone else, no VC should touch this
    // closure is called not the loadMeals func
    func loadMeals(completion: @escaping ([MealData]) -> ()) {
        
        let dataStore = backendless.persistenceService.of(Meal.ofClass())
        
        let dataQuery = BackendlessDataQuery()
        // Only get the Meals that belong to our logged in user!
        dataQuery.whereClause = "ownerId = '\(backendless.userService.currentUser.objectId!)'"
        
        dataStore?.find( dataQuery,
                         
                         response: { (meals: BackendlessCollection?) -> Void in
                            
                            print("Find attempt on all Meals has completed without error!")
                            print("Number of Meals found = \((meals?.data.count)!)")
                            
                            var mealData = [MealData]()
                            
                            for meal in (meals?.data)! {
                                
                                
                                // checks every meal, to collect every instance of a meal in BE, we create the meal, photo set to nil for now
                                let meal = meal as! Meal
                                
                                print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl)\", rating: \"\(meal.rating)\"")
                                
                                let newMealData = MealData(name: meal.name!, photo: nil, rating: meal.rating)
                                
                                if let newMealData = newMealData {
                                    
                                    newMealData.objectId = meal.objectId
                                    newMealData.photoUrl = meal.photoUrl
                                    newMealData.thumbnailUrl = meal.thumbnailUrl
                                    
                                    // append the meals to the data array
                                    mealData.append(newMealData)
                                }
                            }
                            
                            // Whatever meals we found on the database - return them.
                            completion(mealData)
            },
                         
                         error: { (fault: Fault?) -> Void in
                            print("Meals were not fetched: \(fault)")
            }
        )
    }
    // removes meal from the database
    // completion argument takes no arguments and returns nothing
    // says the request occured and the DB deletes it and then its removed from the table
    func removeMeal(mealToRemove: MealData, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        print("Remove Meal: \(mealToRemove.objectId!)")
        
        let dataStore = backendless.persistenceService.of(Meal.ofClass())
        
        _ = dataStore?.removeID(mealToRemove.objectId,
                                
                                response: { (result: NSNumber?) -> Void in
                                    
                                    print("One Meal has been removed: \(result)")
                                    completion()
            },
                                
                                error: { (fault: Fault?) -> Void in
                                    print("Failed to remove Meal: \(fault)")
                                    error()
            }
        )
        }
        
    func removePhotoAndThumbnail(photoUrl: String, thumbnailUrl: String, completion: @escaping () -> (), error: @escaping () -> ()) {
            
            // Get just the file name which is everything after "/files/".
            // In BE, we can't remove files by its full URL name, need to do it this way
            let photoFile = photoUrl.components(separatedBy: "/files/").last
            
            // talking to file service not the other one
            backendless.fileService.remove( photoFile,
                                            
                                            response: { (result: Any!) -> () in
                                                print("Photo has been removed: result = \(result)")
                                                
                                                // Get just the file name which is everything after "/files/".
                                                let thumbnailFile = thumbnailUrl.components(separatedBy: "/files/").last
                                                
                                                self.backendless.fileService.remove( thumbnailFile,
                                                                                     
                                                                                     response: { (result: Any!) -> () in
                                                                                        print("Thumbnail has been removed: result = \(result)")
                                                                                        completion()
                                                    },
                                                                                     
                                                                                     error: { (fault : Fault?) -> () in
                                                                                        print("Failed to remove thumbnail: \(fault)")
                                                                                        error()
                                                    }
                                                )
                },
                                            
                                            error: { (fault : Fault?) -> () in
                                                print("Failed to remove photo: \(fault)")
                                                error()
                }
            )
        }
}