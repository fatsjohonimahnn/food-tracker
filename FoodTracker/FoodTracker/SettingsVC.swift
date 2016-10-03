//
//  SettingsVC.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 10/2/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var createAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() == true {
            createAccount.isHidden = true
        } else {
            createAccount.isHidden = false
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        
        spinner.startAnimating()
        
        
         BackendlessManager.sharedInstance.logoutUser(completion: {
            
            self.spinner.stopAnimating()
            
            self.performSegue(withIdentifier: "goToLogin", sender: sender)
            
            // chance to add code to segue back when we move this button
            
                },
                                                     
            error: { message in
            
            Utility.showAlert(viewController: self, title: "Logout Error", message: message)
        })
    }

    @IBAction func createAccount(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToLogin", sender: sender)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
