//
//  LoginViewController.swift
//  chatBox
//
//  Created by MCUCSIE on 6/14/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func login(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }

            let friendListViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendList")

            self.present(friendListViewController!, animated: true, completion: nil)
        }
    }
}
