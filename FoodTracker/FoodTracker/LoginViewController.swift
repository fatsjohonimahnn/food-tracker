//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/21/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // use below helper method here to give textFields ability to check for input
        emailTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // helper method checks textFields for input, if so enables loginBtn
    func textFieldChanged(textField: UITextField) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            loginBtn.isEnabled = false
        } else {
            loginBtn.isEnabled = true
        }
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.showAlert(viewController: self, title: "Login Error", message: "Please enter a valid email address.")
            return
        }
        
        spinner.startAnimating()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        BackendlessManager.sharedInstance.loginUser(email: email, password: password, completion: {
            
                self.spinner.stopAnimating()
            
                self.performSegue(withIdentifier: "loginToNav", sender: sender)
            },
                
                error: { message in
                    
                    self.spinner.stopAnimating()
                    
                    Utility.showAlert(viewController: self, title: "Login Errors", message: message)
            })
    }
    
    @IBAction func createAccountBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "loginToRegister", sender: sender)
    }
    
// TODO: move this
    @IBAction func logoutBtn(_ sender: UIButton) {
        
        
        BackendlessManager.sharedInstance.logoutUser(completion: {
            
            self.spinner.stopAnimating()
            
            // chance to add code to segue back when we move this button
            
                },
                                                     
            error: { message in
            
            Utility.showAlert(viewController: self, title: "Logout Error", message: message)
        })
    }

    @IBAction func skipBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginToNav", sender: sender)
    }
}
