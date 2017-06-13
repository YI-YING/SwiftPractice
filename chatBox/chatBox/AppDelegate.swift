//
//  AppDelegate.swift
//  chatBox
//
//  Created by MCUCSIE on 6/14/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

