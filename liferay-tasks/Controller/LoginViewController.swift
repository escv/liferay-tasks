//
//  LoginViewController.swift
//  liferay-tasks
//
//  Created by Andre Albert on 26.02.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import UIKit
import LiferayScreens

class LoginViewController : UIViewController, LoginScreenletDelegate {
    
    @IBOutlet var screenlet: LoginScreenlet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenlet?.presentingViewController = self
        self.screenlet?.delegate = self
        
        // prefill fields
        if SessionContext.hasSession {
            self.screenlet?.viewModel.userName = SessionContext.currentBasicUserName
            self.screenlet?.viewModel.password = SessionContext.currentBasicPassword
        }
    }
    
    func screenlet(screenlet: BaseScreenlet,
        onLoginResponseUserAttributes attributes: [String:AnyObject]) {
            println("DELEGATE: onLoginResponse called -> \(attributes)");
            
            self.performSegueWithIdentifier("WorkflowTasksTable", sender: self)
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
    
//    @IBAction func login(sender: AnyObject) {
//        let auth = LRBasicAuthentication(username: usernameField.text, password: passwordField.text)
//        let session = LRSession(server: liferayHostField.text, authentication: auth)
//        let portalService:LRPortalService_v62 = LRPortalService_v62(session: session)
//
//        var e = NSError?()
//        let portalNr = portalService.getBuildNumber(&e).stringValue
//
//        if (portalNr.hasPrefix("62")) {
//            LRCredentialStorage.storeCredentialForServer(liferayHostField.text,
//                username: usernameField.text,
//                password: passwordField.text)
//            
//            // loading initial table list view
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let navCtrl = storyboard.instantiateViewControllerWithIdentifier("WorkflowTasksTable") as! UINavigationController
//            let myTasksTVC = navCtrl.viewControllers.first as! MyTasksTableViewController
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            myTasksTVC.session = session
//            appDelegate.session = session
//            
//            self.showViewController(navCtrl, sender:self)
//        }
//    }
    
}