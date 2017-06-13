//
//  ViewController.swift
//  chatBox
//
//  Created by MCUCSIE on 6/14/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var heightTextField: UITextField!

    @IBOutlet weak var ageTextField: UITextField!

    @IBOutlet weak var myTableView: UITableView!

    var nameList : [String] = []

    override func viewDidLoad() {
        let ref = Database.database().reference()

    }
    
    @IBAction func save(_ sender: UIButton) {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.textLabel?.text = nameList[indexPath.row]

        return cell!
    }
}

