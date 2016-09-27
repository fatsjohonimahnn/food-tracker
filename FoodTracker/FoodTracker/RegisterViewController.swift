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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(_ sender: UIButton) {
    }
    
    @IBAction func cancel(_ sender: UIButton) {
    }
}
