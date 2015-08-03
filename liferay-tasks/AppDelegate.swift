//
//  AppDelegate.swift
//  liferay-tasks
//
//  Created by Andre Albert on 26.02.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var workflowService: LRWorkflowTaskService?
    var session: LRSession?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        self.workflowService = LRWorkflowTaskService()
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // ask user for background mode activation
        let registerUserNotificationSettings = UIApplication.instancesRespondToSelector("registerUserNotificationSettings:")
        if registerUserNotificationSettings {
            
            let types: UIUserNotificationType = UIUserNotificationType.Alert |
                    UIUserNotificationType.Badge |
                    UIUserNotificationType.Sound
            
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
        }
        
        //self.addCertToKeychain()
        
        return true
    }
    
    func application(
        application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData
        ) {
            //Process the deviceToken and send it to your server
            NSLog("My token is: %@", deviceToken)
    }
    
    func application(
        application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: NSError
        ) {
            //Log an error for debugging purposes, user doesn't need to know
            NSLog("Failed to get token; error: %@", error) 
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let lrSession = self.session {
            let service = LRWorkflowTaskService()
            if let lastTimestamp = defaults.objectForKey("lastPollTimestamp") as? String {
                if let service = self.workflowService {
                    service.newTasksAfterTimestamp(lastTimestamp, session: lrSession, success: { (tasks:[WorkflowTask]) -> Void in
                            if (!tasks.isEmpty) {
                                completionHandler(UIBackgroundFetchResult.NewData)
                                let notifiy = UILocalNotification()
                                notifiy.alertBody = "New Workflow Task"
                                application.presentLocalNotificationNow(notifiy)
                                application.applicationIconBadgeNumber += tasks.count
                            }else{
                                completionHandler(UIBackgroundFetchResult.NoData)
                            }
                            return
                        }, failure: { (e:NSError) -> Void in
                            completionHandler(UIBackgroundFetchResult.Failed)
                            return
                    })
              }
           }
        }
        let timestamp = UInt32(NSDate().timeIntervalSince1970)

        defaults.setObject(timestamp.description+"000", forKey: "lastPollTimestamp")
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func addCertToKeychain() {

        let mainbun = NSBundle.mainBundle().pathForResource("pd-test", ofType: "cer")
        var key: NSData = NSData.dataWithContentsOfMappedFile(mainbun!)! as! NSData
        var cert:SecCertificateRef =
            SecCertificateCreateWithData(kCFAllocatorDefault, key).takeRetainedValue()

        var err:OSStatus = noErr

        let secDict = NSDictionary(
            objects: [kSecClassCertificate,cert],
            forKeys: [kSecClass, kSecValueRef]
        )
        
    
        SecItemAdd(secDict as CFDictionaryRef, nil);

    }
}

