//
//  SignUpViewController.swift
//  chatBox
//
//  Created by MCUCSIE on 6/14/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    var ref : DatabaseReference?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
    }
    @IBAction func signUp(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }

            // Change user's profile
            let changeRequest = user?.createProfileChangeRequest()
            changeRequest?.displayName = self.nameTextField.text
            changeRequest?.commitChanges(completion: nil)

            // Write user's profile to database
            let userRef = self.ref?.child("users/\(user!.uid)")
            let userProfile : [String : Any] = ["name" : self.nameTextField.text!]

            userRef?.setValue(userProfile)

            print("Successful create a new count!")

            self.cancel()
        }
    }

    @IBAction func cancel() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
