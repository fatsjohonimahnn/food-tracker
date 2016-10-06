//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/15/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var meals = [MealData]()
    
    let backendless = Backendless.sharedInstance()
    
    var isPresentingVCRegister: Bool? = false
    
    // Create a cache that uses keys of type NSString to point to value types of UIImage.
    // NSCache will dump old cache if we get memory warnings
    var imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NSCache has built in functions like countLimit
        imageCache.countLimit = 50 // Cache up to 50 UIImage(s)
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.width = 105.0
        navigationItem.leftBarButtonItem?.image = UIImage(named: "edit-symbol")
        
        if isPresentingVCRegister == true {
            
            loadSampleMeals()
                        
            isPresentingVCRegister = false
            
            print("\(isPresentingVCRegister)")
            
        } else {
            print ("thePresenter is not RegisterViewController")
        }
            
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
        // calling .loadMeals from BEManager with the closure
        BackendlessManager.sharedInstance.loadMeals { mealData in
            
            self.meals += mealData
            self.tableView.reloadData()
            }
            
        } else {
            
            // Load any saved meals, otherwise load sample data.
            // if user is not logged in, we use the archiver
            if let savedMeals = loadMealsFromArchiver() {
                meals += savedMeals
            } else {
                
                loadSampleMeals()
            }
        }
    }
    
    func loadSampleMeals() {
        
        let photo1 = UIImage(named: "meal1")!
        let meal1 = MealData(name: "Caprese Salad", photo: photo1, rating: 4)!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = MealData(name: "Chicken and Potatoes", photo: photo2, rating: 5)!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = MealData(name: "Pasta with Meatballs", photo: photo3, rating: 3)!
        
        meals += [meal1, meal2, meal3]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: TableView Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "mealTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = meal.name
        
        // don't need this anymore since we are loading thumbnails
        cell.photoImageView.image = nil
        cell.ratingControl.rating = meal.rating

        // For NSCache, if we have the cache key we put it on the cell when it gets created
        if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.thumbnailUrl != nil {
        
            // Fist check if the cache key is available
            if imageCache.object(forKey: meal.thumbnailUrl! as NSString) != nil {
                
                // If the Url for the thumbnail is in the cache already-get the UIImage that belongs to it.
                cell.photoImageView.image = imageCache.object(forKey: meal.thumbnailUrl! as NSString)
                
            } else {
                
                cell.spinner.startAnimating()
                
                // load image from Url as before
                loadImageFromUrl(thumbnailUrl: meal.thumbnailUrl!,
                
                    completion: { data in
                    
                        // We got the image data! Use it ti create a UIImage for our cell's
                        // UIImageView. Then, stop the activity spinner
                        if let image = UIImage(data: data) {
                        
                            cell.photoImageView.image = image
                            
                            // Set new image to be cached
                            // Since we went to the trouble of pulling down the image data and
                            // building a UIImage, lets cache the UIImage using the URL as the key
                            self.imageCache.setObject(image, forKey: meal.thumbnailUrl! as NSString)
                        }
                        
                        cell.spinner.stopAnimating()
                        
                    },
                
                    loadError: {
                        cell.spinner.stopAnimating()
                    })
                }
            } else {
                cell.photoImageView.image = meal.photo
            }
        
            return cell
    }
    
    // updated to use cache to get images that are already loaded
    //func loadImageFromUrl(cell: MealTableViewCell, thumbnailUrl: String) {
    func loadImageFromUrl(thumbnailUrl: String, completion: @escaping (Data) -> (), loadError: @escaping () -> ()) {
        
        // Moved above
        //cell.spinner.startAnimating()
        
        let url = URL(string: thumbnailUrl )!
        
        print("loadImageFromUrl: \(url)")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        completion(data)
                        
                        // Moved above
                        // We got the image data! Use it to create a UIImage for our cell's
                        // UIImageView. Then, stop the activity spinner.
                        //cell.photoImageView.image = UIImage(data: data)
                        //cell.spinner.stopAnimating()
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                    //cell.spinner.stopAnimating()
                    DispatchQueue.main.async {
                        loadError()
                    }
                }
                
            } else {
                print("NSURLSession Error: \(error)")
                //cell.spinner.stopAnimating()
                DispatchQueue.main.async {
                    loadError()
                }
            }
        })
        
        task.resume()
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let mealToRemove = meals[indexPath.row]
            
            if BackendlessManager.sharedInstance.isUserLoggedIn() && mealToRemove.name != "Caprese Salad" && mealToRemove.name != "Chicken and Potatoes" && mealToRemove.name != "Pasta with Meatballs"{
                
                // Find the MealData in the data source we wish to delete
                
                BackendlessManager.sharedInstance.removeMeal(mealToRemove: mealToRemove,
                                                             
                    completion: {
                                                                
                        // If it was removed from the database, now delete the row from the data source
                        self.meals.remove(at: (indexPath as NSIndexPath).row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    },
                    
                    error: {
                                                                
                        // It was NOT removed - tell user and DON'T delete the row from data source
                        let alertController = UIAlertController(title: "Remove Failed",
                                    message: "Oops! We couldn't remove your Meal at this time.",
                                    preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                                                                
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                )
            } else {
                
                // Delete the row from the data source
                meals.remove(at: indexPath.row)
                
                // Save the archivers meals array when deleted
                saveMealsToArchiver()
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        } else if editingStyle == .insert {
            
            navigationItem.leftBarButtonItem?.title = ""
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            let mealDetailViewController = segue.destination as! MealViewController
            
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? MealTableViewCell {
                
                let indexPath = tableView.indexPath(for: selectedMealCell)!
                let selectedMeal = meals[(indexPath as NSIndexPath).row]
                mealDetailViewController.meal = selectedMeal
            }
        }
        else if segue.identifier == "addItem" {
            
            print("Adding new meal.")
        }
    }
    
    @IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
    
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            // check if a row is selected
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing meal.
                meals[(selectedIndexPath as NSIndexPath).row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            } else {
                
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                // append the meal to the array meals
                meals.append(meal)
                // insert the meal into the tableview
                tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
            
            if !BackendlessManager.sharedInstance.isUserLoggedIn() {
                // Save the meals to archiver
                saveMealsToArchiver()
            }
        }
    }
    
    // MARK: NSCoding
    
    func saveMealsToArchiver() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: MealData.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
    }
    
    func loadMealsFromArchiver() -> [MealData]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: MealData.ArchiveURL.path) as? [MealData]
    }
}
