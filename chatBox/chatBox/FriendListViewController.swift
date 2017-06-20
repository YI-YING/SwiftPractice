//
//  FriendListViewController.swift
//  chatBox
//
//  Created by MCUCSIE on 6/17/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var friendID: [String] = []
    var friendNames: [String] = []
    var currentUser: User?
    var friendsRef: DatabaseReference?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hidde tableview before data loading complete
        self.stackView.isHidden = true

        // Get current user ID and friend list path
        currentUser = Auth.auth().currentUser
        friendsRef = Database.database().reference().child("users/\(currentUser!.uid)/friends")

        // Get friend list and observe its value changing
        friendsRef?.observe(.value, with: { (snapShot) in
            self.activeIndicator.stopAnimating()
            self.stackView.isHidden = false

            if !snapShot.exists() {
                return
            }
            
            let friendArray = snapShot.children.allObjects as! [DataSnapshot]
            for snap in friendArray {
                self.friendID.append(snap.key)
                self.friendNames.append(snap.value as! String)
            }

            self.friendTableView.reloadData()
        })
    }

    // MARK: - Tableview data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendID.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        cell?.textLabel?.text = self.friendNames[indexPath.row]

        return cell!
    }

    // MARK: - methods

    // Sign out
    @IBAction func logout(_ sender: Any) {
        self.friendsRef?.removeAllObservers()

        do {
            try Auth.auth().signOut()

            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: - Navigation methods

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get destination controller and indexPath
        let mainController = segue.destination as! MainViewController
        let cell = sender as! UITableViewCell
        let indexPath = self.friendTableView.indexPath(for: cell)

        // Get maincontroller's friend ID and title
        let friendID = self.friendID[(indexPath?.row)!]
        let title = self.friendNames[(indexPath?.row)!]

        mainController.senderId = self.currentUser?.uid
        mainController.senderDisplayName = self.currentUser?.displayName
        mainController.navigationBarTitle = title
        mainController.friendID = friendID
    }
}
