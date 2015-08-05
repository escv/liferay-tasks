//
//  LoginViewController.swift
//  liferay-tasks
//
//  Created by Andre Albert on 26.02.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import UIKit
import LiferayScreens
import LRPush

class LoginViewController : UIViewController, LoginScreenletDelegate {
    
    @IBOutlet var screenlet: LoginScreenlet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenlet?.presentingViewController = self
        self.screenlet?.delegate = self
        
        SessionContext.loadSessionFromStore()
        
        // prefill fields
        if SessionContext.hasSession {
            self.screenlet?.viewModel.userName = SessionContext.currentBasicUserName
            self.screenlet?.viewModel.password = SessionContext.currentBasicPassword
        } 
    }
    
    func screenlet(screenlet: BaseScreenlet,
        onLoginResponseUserAttributes attributes: [String:AnyObject]) {
            println("DELEGATE: onLoginResponse called -> \(attributes)");
            
           SessionContext.storeSession()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let deviceToken: AnyObject? = defaults.objectForKey("deviceToken")
            
            let lrPush = LRPush.withSession(SessionContext.createSessionFromCurrentSession()!)
            lrPush.registerDeviceTokenData(deviceToken as! NSData)
            
            self.performSegueWithIdentifier("initialSegue", sender: self)
    }
    
    func screenlet(screenlet: BaseScreenlet,
        onLoginError error: NSError) {
            println("DELEGATE: onLoginError called -> \(error)");
    }
    
    func onScreenletCredentialsSaved(screenlet: BaseScreenlet) {
        println("DELEGATE: onCredentialsSaved called");
    }
    
    func onScreenletCredentialsLoaded(screenlet: BaseScreenlet) {
        println("DELEGATE: onCredentialsLoaded called");
    }
}