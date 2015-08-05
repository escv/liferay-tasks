//
//  PreviewArticleViewController.swift
//  liferay-tasks
//
//  Created by Andre Albert on 03.03.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import Foundation
import UIKit
import LiferayScreens
//import PKHUD

class PreviewArticleViewController : UIViewController, UIActionSheetDelegate, UIWebViewDelegate, WebContentDisplayScreenletDelegate {
    
    var task:WorkflowTask?
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var screenlet: WebContentDisplayScreenlet!
    @IBOutlet weak var actionSheetButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenlet?.presentingViewController = self
        self.screenlet?.delegate = self
        
        self.actionSheetButton.enabled = true;
        
        //            self.screenlet.groupId = 10182
        //            self.screenlet.articleId = self.task!.articleId
        //            self.screenlet.articleId = "11914"
        
        //         self.screenlet.loadWebContent()
        
        if let journalPreviewURL = self.task?.previewURL  {
            
            self.webView.delegate = self
            
            let server = SessionContext.createBatchSessionFromCurrentSession()?.server
            let req = NSMutableURLRequest(URL: NSURL(string: server! + journalPreviewURL)!)
            self.webView.loadRequest(req)
        }
    }
    
    /**
    * Creates a Action Sheet with all the possible transition used to proceed workflow
    **/
    @IBAction func openActionSheet(sender: UIBarButtonItem) {
        let sheet = UIActionSheet(title: "Workflow Transitions", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        
        if let trans = self.task?.transitions {
            for t in trans {
                sheet.addButtonWithTitle(t.capitalizedString)
            }
        }
        sheet.showFromBarButtonItem(sender, animated: true)
    }
    
    /**
    * Delegate operation triggered when pressing an action sheet button
    **/
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            return
        }
        let transition = self.task!.transitions[buttonIndex-1]
        
        let alert = UIAlertController(title: transition.capitalizedString, message: "Please enter a comment", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler( nil )
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            let tf = alert.textFields?.first as? UITextField

            if let lrSession = SessionContext.createSessionFromCurrentSession() {
                let taskService = LRWorkflowTaskService()
                taskService.completeTask(self.task!.workflowTaskId, transition: transition, comment: tf!.text, session: lrSession, success: { (tasks:[WorkflowTask]) -> Void in
                    // enable action because transitions have changed after execution
//                    HUDController.sharedController.contentView = HUDContentView.TitleView(title: "Success", image: nil)
//                    HUDController.sharedController.show()
//                    HUDController.sharedController.hide(afterDelay: 2.0)
                    self.actionSheetButton.enabled = false;
                })
            }

        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func screenlet(screenlet: WebContentDisplayScreenlet, onWebContentError error: NSError) {
        NSLog("onWebContentError: %@", error)
    }
    
    func screenlet(screenlet: WebContentDisplayScreenlet, onWebContentResponse html: String) -> String? {
        NSLog("onWebContentResponse: %@", html)
        return nil
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
//        let contentView = HUDContentView.ProgressView()
//        HUDController.sharedController.contentView = contentView
//        HUDController.sharedController.show()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
//        HUDController.sharedController.hide(animated: true)
    }
}