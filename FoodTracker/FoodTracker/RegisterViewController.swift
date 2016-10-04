//
//  RegisterViewController.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/27/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
 //   var isPresentingVCRegister: Bool = false
    
    let backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adds ability to check if textFields have certain input
        emailTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // helper function to check if textFields have input, used in viewDidLoad
    func textFieldChanged(textField: UITextField) {
        
        if emailTextField.text == "" || passwordTextField.text == "" || passwordConfirmTextField.text == "" {
            registerBtn.isEnabled = false
        } else {
            registerBtn.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let barViewControllers = segue.destination as! UITabBarController
        let nav = barViewControllers.viewControllers![0] as! UINavigationController
        let destinationViewController = nav.topViewController as! MealTableViewController
        
        destinationViewController.isPresentingVCRegister = true
        
    }
    
    @IBAction func register(_ sender: UIButton) {
        
        registerBtn.isEnabled = false 
        
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.showAlert(viewController: self, title: "Registration Error", message: "Please enter a valid email address")
            return
        }
        
        if passwordTextField.text != passwordConfirmTextField.text {
            Utility.showAlert(viewController: self, title: "Registration Error", message: "Password confirmation failed. Please enter your password try again.")
            return
        }
        
        spinner.startAnimating()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        BackendlessManager.sharedInstance.registerUser(email: email, password: password , completion: {
            
            BackendlessManager.sharedInstance.loginUser(email: email, password: password , completion: {
                
                    self.spinner.stopAnimating()
                
                    self.performSegue(withIdentifier: "registerToTV", sender: sender)
                },
                                                        
                error: { message in
                    
                    self.spinner.stopAnimating()
                    
                    Utility.showAlert(viewController: self, title: "Login Error", message: message)
                })
            
            },
            
            error: { message in
        
                self.spinner.stopAnimating()
        
                Utility.showAlert(viewController: self, title: "Register Error", message: message)
        })
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        spinner.stopAnimating()
        
        performSegue(withIdentifier: "registerToLogin", sender: sender)
    }
}
