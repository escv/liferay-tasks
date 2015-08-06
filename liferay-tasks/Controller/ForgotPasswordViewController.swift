//
//  ForgotPasswordViewController.swift
//  liferay-tasks
//
//  Created by Peter Kurzok on 05.08.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import UIKit
import LiferayScreens

class ForgotPasswordViewController: UIViewController, ForgotPasswordScreenletDelegate {

    @IBOutlet var screenlet: ForgotPasswordScreenlet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.screenlet.delegate = self
        self.screenlet.presentingViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func screenlet(screenlet: ForgotPasswordScreenlet,
        onForgotPasswordSent passwordSent: Bool) {
         
            NSLog("onForgotPasswordSent %@", passwordSent);
            
            self.performSegueWithIdentifier("forgotPasswordLogin", sender: self)
    }
    
    func screenlet(screenlet: ForgotPasswordScreenlet,
        onForgotPasswordError error: NSError) {
            
            NSLog("onForgotPasswordError %@", error)
    }
}
