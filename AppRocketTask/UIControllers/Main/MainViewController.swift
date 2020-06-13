//
//  MainViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 13/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit
import FirebaseAuth


class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().signInAnonymously(completion: nil)

        // Do any additional setup after loading the view.
    }

    @IBAction func signup(_ sender: Any) {
        self.present(SignupViewController(), animated: false, completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        self.present(LoginViewController(), animated: false, completion: nil)
    }
    
}
