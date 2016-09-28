//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/14/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var saveSpinner: UIActivityIndicatorView!
    
    /*
     This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: MealData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        // self here refers to VC bc in VC's scope
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            ratingControl.rating = meal.rating
            
            if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.photoUrl != nil {
                loadImageFromUrl(imageView: photoImageView, photoUrl: meal.photoUrl!)
            } else {
                photoImageView.image = meal.photo
            }
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // MARK: UITextFieldDelegate
    
    // UITextFieldDelegate, called when Return tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
    
    // UITextFieldDelegate, called when editing session begins, or when keyboard displayed
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    //  helper method to disable Save button if the text field is empty.
    func checkValidMealName() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // UITextFieldDelegate, called after textfield resigns first responder
    func textFieldDidEndEditing(_ textField: UITextField) {
        // helper method to check if text field has text, enables save button if so
        checkValidMealName()
        // sets title of scene to textfield
        navigationItem.title = textField.text
    }
    
    
    
    
    // MARK: UIImagePickerControllerDelegate
    
    
    // From UIImagePickerControllerDelegate called when image picker’s Cancel button tapped
    // opportunity to dismiss the UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    // From UIImagePickerControllerDelegate called when photo selected
    // opportunity to do something with image ex: display in UI
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // If we already have a URL for an image - the user wants to do an image replacement.
        if meal?.photoUrl != nil {
            // book keeping variable for keeping track of user changing the picture
            meal?.replacePhoto = true
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: Navigation
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        // turn off save button when pressed once
        self.saveButton.isEnabled = false
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // configures meal property with appropriate values before segue executes
        if meal == nil {
            
            meal = MealData(name: name, photo: photo, rating: rating)
            
        } else {
            
            meal?.name = name
            meal?.photo = photo
            meal?.rating = rating
        }
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
            
            // We're logged in - attempt to save to Backendless!
            saveSpinner.startAnimating()
            
            BackendlessManager.sharedInstance.saveMeal(mealData: meal!,
                                                       
                completion: {
                                                        
                    // It was saved to the database!
                    self.saveSpinner.stopAnimating()
                                                        
                                                        
                    self.meal?.replacePhoto = false // Reset this just in case we did a photo replacement.
                   self.performSegue(withIdentifier: "unwindToMealList", sender: self)
                },
                                                       
                error: {
                                                        
                // It was NOT saved to the database! - tell the user and DON'T call performSegue.
                self.saveSpinner.stopAnimating()
                                                        
                let alertController = UIAlertController(title: "Save Error",
                            message: "Oops! We couldn't save your Meal at this time.",
                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    self.saveButton.isEnabled = true
            })
            
        } else {
            
            // We're not logged in - just unwind and have MealTableViewController 
            // save later using NSKeyedArchiver.
            self.performSegue(withIdentifier: "unwindToMealList", sender: self)
        }
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation),
        // this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // MARK: Actions
    

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a VC that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func loadImageFromUrl(imageView: UIImageView, photoUrl: String) {
        
        saveSpinner.startAnimating()
        
        let url = URL(string: photoUrl)!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        
                        // We got the image data! Use it to create a UIImage for our cell's
                        // UIImageView.
                        imageView.image = UIImage(data: data)
                        self.saveSpinner.stopAnimating()
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                }
                
            } else {
                print("NSURLSession Error: \(error)")
            }
        })
        
        task.resume()
    }
}

