//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/21/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // Test User Data
    let EMAIL = "ios_user@gmail.com" // Doubles as User Name
    let PASSWORD = "password"
    
    let backendless = Backendless.sharedInstance()!

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
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            
            // The user has a valid user token so we know for sure the user is already logged!
            print("User is already logged: \(isValidUser?.boolValue)");
            //self.performSegue(withIdentifier: "loginToNav", sender: sender)
            
        } else {
            
            // If we were unable to find a valid user token, the user is not logged in and they'll
            // need to login. In a real app, this where we would send the user to a login screen to
            // collect their user name and password for the login attempt. For testing purposes,
            // we will simply login a test user using a hard coded user name and password.
            
            // Please note for a user to stay logged in, we had to make a call to
            // backendless.userService.setStayLoggedIn(true) and pass true.
            // This asks that the user should stay logged in by storing or caching the user's login
            // information so future logins can be skipped next time the user launches the app.
            // For this sample this call was made in the AppDelegate in didFinishLaunchingWithOptions.
            
            backendless.userService.login( EMAIL, password: PASSWORD,
                                           
                                           response: { (user: BackendlessUser?) -> Void in
                                            print("User logged in: \(user!.objectId)")
                                            self.performSegue(withIdentifier: "loginToNav", sender: sender)
                },
                                           
                                           error: { (fault: Fault?) -> Void in
                                            print("User failed to login: \(fault)")
                }
            )
        }
        
        
        // If the user is not logged in, register the test user,
        // and if that succeeds, go ahead and log them in
        
        let user: BackendlessUser = BackendlessUser()
        user.email = EMAIL as NSString!
        user.password = PASSWORD as NSString!
        
        backendless.userService.registering( user,
                                             
                                             response: { (user: BackendlessUser?) -> Void in
                                                print("User was registered: \(user?.objectId)")
                                                self.performSegue(withIdentifier: "loginToNav", sender: sender)
            },
                                             
                                             error: { (fault: Fault?) -> Void in
                                                print("User failed to register: \(fault)")
            }
        )
    }
    
    @IBAction func logoutBtn(_ sender: UIButton) {
                
        print( "logoutBtn called!" )
        
        // First, check if the user is actually logged in.
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            
            // If they are currently logged in - go ahead and log them out!
            
            backendless.userService.logout( { (user: Any!) -> Void in
                print("User logged out!")
                },
                                            
                                            error: { (fault: Fault?) -> Void in
                                                print("User failed to log out: \(fault)")
                }
            )
            
        } else {
            
            // If we were unable to find a valid user token, the user is already logged out.
            
            print("User is already logged out: \(isValidUser?.boolValue)");
        }
    }

    


    @IBAction func skipBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginToNav", sender: sender)
    }
}
