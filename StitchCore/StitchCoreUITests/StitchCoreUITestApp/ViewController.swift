//
//  ViewController.swift
//  StitchCoreUITestApp
//
//  Created by Jason Flax on 1/8/18.
//  Copyright © 2018 mongodb. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let shared = GIDSignIn.sharedInstance()
        shared?.clientID = "405021717222-81hotqfbpmdavu7s03b5s6c9ujfjjig4.apps.googleusercontent.com"
        shared?.delegate = self
        shared?.uiDelegate = self
        shared?.signIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

