//
//  MyTasksTableViewController.swift
//  liferay-tasks
//
//  Created by Andre Albert on 02.03.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import Foundation
import UIKit
import LiferayScreens
import JGProgressHUD

class MyTasksTableViewController : UITableViewController {

    let MY_TASKS_SECTION = 0
    let GROUP_TASKS_SECTION = 1
    
    var myTasks:[WorkflowTask] = []
    var groupTasks:[WorkflowTask] = []
    let taskService = LRWorkflowTaskService()
    
    let hud: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
        if let refresh = self.refreshControl {
            refresh.tintColor = UIColor.whiteColor()
            refresh.addTarget(self, action: "reload", forControlEvents: UIControlEvents.ValueChanged)
        }
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "BlurredBG"))
    }
    
    /**
    * Reload both collections (assigned and group tasks)
    **/
    func reload() {
        
        self.hud.showInView(self.view)
        
        if let lrSession = SessionContext.createSessionFromCurrentSession() {
            taskService.loadMyTasks(lrSession, success: { (tasks:[WorkflowTask]) -> Void in
                self.myTasks = tasks
                self.tableView.reloadData()
                if let refresher = self.refreshControl {
                    refresher.endRefreshing()
                }
                self.hud.dismissAnimated(true)
            })
            taskService.loadGroupTasks(lrSession, success: { (tasks:[WorkflowTask]) -> Void in
                self.groupTasks = tasks
                self.tableView.reloadData()
                if let refresher = self.refreshControl {
                    refresher.endRefreshing()
                }
                self.hud.dismissAnimated(true)
            })
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? myTasks.count : groupTasks.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section==self.MY_TASKS_SECTION ? "My Tasks" : "Group Tasks"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkflowTaskCell") as! WorkflowTaskTableViewCell
        let task = self.taskForIndexPath(indexPath)
        
        cell.nameLabel.text = task.title
        cell.entryTypeLabel.text = task.entryType
        cell.detailsLabel.text = "\(task.initiator) - \(task.createDate)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    
        let task = self.taskForIndexPath(indexPath)
        var actions:[UITableViewRowAction] = []
        
        if (indexPath.section == self.GROUP_TASKS_SECTION) {
            actions.append(UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Assign to me", handler: self.assignToMeAction))
        } else {
            for trans in task.transitions {
                actions.append(self.createCompleteTaskAction(task, transition: trans))
            }
        }
        return actions
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        v.backgroundView!.backgroundColor = UIColor(red: 40/255.0, green: 105/255.0, blue: 140/255.0, alpha: 1.0)
        v.textLabel.textColor = UIColor.whiteColor()
    }
    
    private func assignToMeAction(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void {
        let task = self.taskForIndexPath(indexPath)
        
        if let lrSession = SessionContext.createSessionFromCurrentSession() {
            self.taskService.assignMeTask(task.workflowTaskId, session: lrSession, success: { (tasks:[WorkflowTask]) -> Void in
                //prepare
                self.tableView.beginUpdates()
                
                self.groupTasks.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0), inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                self.myTasks.append(task)
                // commit
                self.tableView.endUpdates()
            })
        }
    }
    
    private func createCompleteTaskAction(task:WorkflowTask, transition:String) -> UITableViewRowAction {
        return UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: transition.capitalizedString, handler: {
            (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let alert = UIAlertController(title: transition.capitalizedString, message: "Please enter a comment", preferredStyle: UIAlertControllerStyle.Alert)
            
            // configure alert dialog
            alert.addTextFieldWithConfigurationHandler( nil )
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                let tf = alert.textFields?.first as? UITextField
                if let lrSession = SessionContext.createSessionFromCurrentSession() {
                    self.taskService.completeTask(task.workflowTaskId, transition: transition, comment: tf!.text, session: lrSession, success: { (tasks:[WorkflowTask]) -> Void in
                        // remove the task if after processing, it is complete and nothing to do
                        if let isCompleted = tasks.first?.completed {
                            if (isCompleted) {
                                self.tableView.beginUpdates()
                                self.myTasks.removeAtIndex(indexPath.row)
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                                self.tableView.endUpdates()
                            }
                        }
                    })
                }
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "previewArticle") {
            let previewVC = segue.destinationViewController as! PreviewArticleViewController
            if let path = self.tableView.indexPathForSelectedRow() {
                let task = self.taskForIndexPath(path)
                LRCredentialStorage.getServer()
                previewVC.task = task
            }
        }
    }
    
    private func taskForIndexPath(indexPath:NSIndexPath) -> WorkflowTask {
        return indexPath.section == self.MY_TASKS_SECTION ? self.myTasks[indexPath.row] : self.groupTasks[indexPath.row]
    }
    
    @IBAction func logoutPressed(sender: AnyObject) {
        
        SessionContext.removeStoredSession()
        self.performSegueWithIdentifier("logout", sender: self)
    }
}
