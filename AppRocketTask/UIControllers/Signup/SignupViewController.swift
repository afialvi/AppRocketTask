//
//  SignupViewController.swift
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

class SignupViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
   
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }

    @IBAction func signup(_ sender: Any) {
           
        Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!) { (user, error) in
        
       if error == nil {
        print("Success signed up user: \(user?.user.email)")
        self.ref?.child("users").child((user?.user.uid)!).setValue(["username": self.emailTF.text!])
        self.present(AllUsersViewController(), animated: false, completion: nil)
        
        
       } else {
        print("Error: \(error.debugDescription)")
        
       }
        
       }
    }
    
    
    
    
}
