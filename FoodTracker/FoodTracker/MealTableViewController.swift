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
    
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            
            meals += savedMeals

        } else {
            // Load the sample data.
            loadSampleMeals()
        }
        
        
        
// TODO: Test save to BE
        
        let meal = BEMeal()
        meal.name = "Meal Name"
        meal.photo = "Photo"
        meal.rating = 5
        
        let backendless = Backendless.sharedInstance()!
        
        backendless.data.save( meal,
                               
                               response: { (entity: Any?) -> Void in
                                
                                let meal = entity as! BEMeal
                                
                                print("BEMeal was saved: \(meal.objectId!), name: \(meal.name), rating: \"\(meal.rating)\"")
            },
                               
                               error: { (fault: Fault?) -> Void in
                                print("Comment failed to save: \(fault)")
            }
        )
        
        

    }
   
    func checkIfLoggedIn() -> Bool {
        
        let backendless = Backendless.sharedInstance()!
        
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            return true
        } else {
            return false
        }
    }
    
    func loadSampleMeals() {
        
        let photo1 = UIImage(named: "meal1")!
        let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4)!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5)!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3)!
        
        meals += [meal1, meal2, meal3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "mealTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    
    @IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            // check if a row is selected
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                
                // Update an existing meal
                meals[(selectedIndexPath as NSIndexPath).row] = meal
                // Update the tableView
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new meal
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                // append the meal to the array meals
                meals.append(meal)
                // insert the meal into the tableView
                tableView.insertRows(at: [newIndexPath], with: .bottom)
                
            }
            // Save the meals.
            saveMeals()
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
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
        
            // Delete the row from the data source
            meals.remove(at: (indexPath as NSIndexPath).row)
            
            //saves meals array whenever a meal is deleted
            saveMeals()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // MARK: NSCoding
    
    func saveMeals() {
        
        if checkIfLoggedIn() {
            
 //           let backendless = Backendless.sharedInstance()!
            
//            let cellIdentifier = "mealTableViewCell"
//            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MealTableViewCell
//
//            let meal: BEMeal
//            meal.name = cell.nameLabel.text!
//            meal.rating = cell.ratingControl.rating
//            meal.photo = cell.imageView?.description
//            
//            backendless.data.save( meal,
//                                   
//                                   response: { (entity: Any?) -> Void in
//                                    
//                                    let meal = entity as! BEMeal
//                                    
//                                    print("BEMeal was saved: \(meal.objectId!), name: \(meal.name), photo: \(meal.photo), rating: \"\(meal.rating)\"")
//                },
//                                   
//                                   error: { (fault: Fault?) -> Void in
//                                    print("Comment failed to save: \(fault)")
//                }
//            )
            
        } else {
            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
            if !isSuccessfulSave {
                print("Failed to save meals...")
            }
        }
    }
    
    // this is unarchiving meals from disk see NSUserDefaults
    func loadMeals() -> [Meal]? {
            
            
//            if checkIfLoggedIn() {
//                
//                
//                let backendless = Backendless.sharedInstance()!
//                let dataStore = backendless.persistenceService.of(BEMeal.ofClass())
//                
//                dataStore?.find(
//                    
//                    { (beMeals: BackendlessCollection?) -> Void in
//                        
//                        print("Find attempt on all Comments has completed without error!")
//                        print("Number of Comments found = \((beMeals?.data.count)!)")
//                        
//                        for meal in (beMeals?.data)! {
//                            
//                            let meal = meal as! BEMeal
//                            
//                            print("Meal: \(meal.objectId!), rating: \"\(meal.rating)\"")
//                        }
//                    },
//                    
//                    error: { (fault: Fault?) -> Void in
//                        print("Comments were not fetched: \(fault)")
//                    }
//                )
//                
//                
//                return 
//                
//                
//            } else {
                return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
//            }
    }

}
