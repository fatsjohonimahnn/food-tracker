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
    
    var isSocialLogin: Bool? = false
    
    let APP_ID =  "<replace-with-your-app-id>"
    let SECRET_KEY = "<replace-with-your-secret-key>"
    let VERSION_NUM = "v1"
    
    func initApp() {
        
        // First, init Backendless! called in AppDelegate when app didFinishLaunching
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
    
    func registerUser(email: String, password: String, completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        let user: BackendlessUser = BackendlessUser()
        user.email = email as NSString!
        user.password = password as NSString!
        
        backendless.userService.registering( user,
            
            response: { (user: BackendlessUser?) -> Void in
                print("User was registered: \(user?.objectId)")
                completion()
            },
            
            error: { (fault: Fault?) -> Void in
                print("User failed to register: \(fault)")
                error((fault?.message)!)
            }
        )
    }
    
    func loginUser(email: String, password: String, completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        backendless.userService.login( email, password: password,
        
            response: { (user: BackendlessUser?) -> Void in
                print("User logged in: \(user!.objectId)")
                completion()
            },
            
            error: { (fault: Fault?) -> Void in
                print("User failed to login: \(fault)")
                error((fault?.message)!)
        })
    }
    
    func handleOpen(open url: URL, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        print("handleOpen: url scheme = \(url.scheme)")
        
        let user = backendless.userService.handleOpen(url)
        
        if user != nil {
            print("handleOpen: user = \(user)")
            completion()
        } else {
            error()
        }
    }
    
    func loginViaFacebook(completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        backendless.userService.easyLogin(withFacebookFieldsMapping: ["email":"email"], permissions: ["email"],
            
            response: {(result : NSNumber?) -> () in
                print ("Result: \(result)")
                self.isSocialLogin = true
                completion()
            },
            
            error: { (fault : Fault?) -> () in
                print("Server reported an error: \(fault)")
                error((fault?.message)!)
        })
    }
    
    func loginViaTwitter(completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        backendless.userService.easyLogin(withTwitterFieldsMapping: ["email":"email"],
                                          
            response: {(result : NSNumber?) -> () in
                print ("Result: \(result)")
                self.isSocialLogin = true 
                completion()
            },
                                          
            error: { (fault : Fault?) -> () in
                print("Server reported an error: \(fault)")
                error((fault?.message)!)
        })
    }

    
    func logoutUser(completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        // First, check if user is actually logged in
        if isUserLoggedIn() {
            
            // If they are currently logged in - go ahead and log them out
            backendless.userService.logout( { (user: Any!) -> Void in
                    print("User logged out!")
                    completion()
                },
                                            
                error: { (fault: Fault?) -> Void in
                    print("User failed to log out: \(fault)")
                    error((fault?.message)!)
                })
            
        } else {
            
            print("User is already logged out!");
            completion()
        }
    }
    
    func savePhotoAndThumbnail(mealToSave: Meal, photo: UIImage, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        //
        // Upload the thumbnail first, bc if we cant save a small thumbnail, how can we save a large image 
        //
        
        
        // creates a universal unique identifier
        let uuid = NSUUID().uuidString
        //print("\(uuid)")
        
        // create the thumbnail
        let size = photo.size.applying(CGAffineTransform(scaleX: 0.75, y: 0.75))
        let hasAlpha = false
        let scale: CGFloat = 0.1
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        photo.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1.0);
        
        //first attempt to Upload
        backendless.fileService.upload(
            // put the thumbnail in a photos folder and give the uuid a "thumb" header
            "photos/\(backendless.userService.currentUser.objectId!)/thumb_\(uuid).jpg",
            content: thumbnailData,
            overwrite: true,
            
            // response closure for success in BE
            response: { (uploadedFile: BackendlessFile?) -> Void in
                print("Thmbnail image uploaded: \(uploadedFile?.fileURL!)")
                
                // set the Meal class equal to the DB file
                mealToSave.thumbnailUrl = uploadedFile?.fileURL!
                
                //
                // Upload full size photo, if thumbnail was successful
                //
                
                // take the fullsize image but lower its quality to .2
                let fullSizeData = UIImageJPEGRepresentation(photo, 0.5);
                
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
    
    // MealData is the old class that we use for persisting data on the phone archiver
    // It shares properties with Meal class on BE so we can still use MealData in the parameter
    // HOWEVER, we need to set the acutal meal to save as the BE Meal class
    func saveMeal(mealData: MealData, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        // MealData shares objectId with Meal
        if mealData.objectId == nil {
            
            //
            // Create a new Meal along with a photo and thumbnail image
            //
            
            
            // Make sure we are using the BE Meal class 
            // and save the data from MealData to the BE Meal
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
                            
                            // this is where we set the MealData from TVC on the Meal
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
            
            // are we replacing the MealData photo? set to true
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
                            let oldMeal = meal as! Meal
                            
                            // Cache old URLs for removal!
                            let oldPhotoUrl = oldMeal.photoUrl!
                            let oldthumbnailUrl = oldMeal.thumbnailUrl!
                            
                            //Update the Meal with the new dataStore
                            oldMeal.name = mealData.name
                            oldMeal.rating = mealData.rating
                            oldMeal.photoUrl = mealToSave.photoUrl
                            oldMeal.thumbnailUrl = mealToSave.thumbnailUrl
                            
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
    
    // Updated to allow error throwing for pull-to-refresh func in MTVC
    // completion is a closure that when called points to an array of MealData
    // job is to load and hand off to someone else, no VC should touch this
    // closure is called not the loadMeals func
    func loadMeals(completion: @escaping ([MealData]) -> (), error: @escaping () -> ()) {
        
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
        
     //   print("Remove Meal: \(mealToRemove.objectId!)")
        
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
