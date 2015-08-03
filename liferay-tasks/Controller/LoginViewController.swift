//
//  LoginViewController.swift
//  liferay-tasks
//
//  Created by Andre Albert on 26.02.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var liferayHostField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prefill fields
        if let credential = LRCredentialStorage.getCredential() {
            usernameField.text = credential.user
            passwordField.text = credential.password
            liferayHostField.text = LRCredentialStorage.getServer()
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        let auth = LRBasicAuthentication(username: usernameField.text, password: passwordField.text)
        let session = LRSession(server: liferayHostField.text, authentication: auth)
        let portalService:LRPortalService_v62 = LRPortalService_v62(session: session)

        var e = NSError?()
        let portalNr = portalService.getBuildNumber(&e).stringValue

        if (portalNr.hasPrefix("62")) {
            LRCredentialStorage.storeCredentialForServer(liferayHostField.text,
                username: usernameField.text,
                password: passwordField.text)
            
            // loading initial table list view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navCtrl = storyboard.instantiateViewControllerWithIdentifier("WorkflowTasksTable") as! UINavigationController
            let myTasksTVC = navCtrl.viewControllers.first as! MyTasksTableViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            myTasksTVC.session = session
            appDelegate.session = session
            
            self.showViewController(navCtrl, sender:self)
        }
    }
    
}