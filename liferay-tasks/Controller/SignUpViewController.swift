//
//  SignUpViewController.swift
//  liferay-tasks
//
//  Created by Peter Kurzok on 05.08.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import UIKit
import LiferayScreens

class SignUpViewController: UIViewController, SignUpScreenletDelegate {

    @IBOutlet var screenlet: SignUpScreenlet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.screenlet?.presentingViewController = self
        self.screenlet?.delegate = self
        
        self.screenlet.autoLogin = true
        self.screenlet.saveCredentials = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func screenlet(screenlet: SignUpScreenlet,
        onSignUpResponseUserAttributes attributes: [String:AnyObject]) {
            
            NSLog("onSignUpResponseUserAttributes %@", attributes)
            
            self.performSegueWithIdentifier("loginSignedUp", sender: self);
    }
    
    func screenlet(screenlet: SignUpScreenlet,
        onSignUpError error: NSError) {
            
            NSLog("onSignUpError %@", error)
    }
}
