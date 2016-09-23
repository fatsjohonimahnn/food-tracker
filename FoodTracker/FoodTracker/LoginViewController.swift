//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/21/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        // First, check if the user is already logged in. If they are, we don't need to
        // ask them to login again.
        
        if !BackendlessManager.sharedInstance.isUserLoggedIn() {
            // only being used becuase we don't have a registration page
            BackendlessManager.sharedInstance.registerTestUser()
            performSegue(withIdentifier: "loginToNav", sender: sender)
        } else {
            performSegue(withIdentifier: "loginToNav", sender: sender)
        }
    }
    
    @IBAction func logoutBtn(_ sender: UIButton) {
        
        BackendlessManager.sharedInstance.logoutTestUser()
    }

    


    @IBAction func skipBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginToNav", sender: sender)
    }
}
