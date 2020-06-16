//
//  LoginViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 12/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase


class LoginViewController: UIViewController {
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailTF.text!, password: self.passwordTF.text!) { (result, error) in
            if error == nil{
                self.present(WidgetsViewController(), animated: false, completion: nil)
            }
            else{
                
            }
        }
        
    }
    
    
    
}
