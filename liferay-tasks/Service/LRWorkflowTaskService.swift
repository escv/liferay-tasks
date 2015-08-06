//
//  LRWorkflowTaskService.swift
//  liferay-tasks
//
//  Created by Andre Albert on 02.03.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import Foundation
import LiferayScreens

/**
* Central service for workflow related operation which internally invokes the liferay remote api
**/
class LRWorkflowTaskService {
    
    let myTasksCmd = ["/liferay-tasks-portlet.workflowtask/my-workflow-tasks":["companyId":"5"]]
    let groupTasksCmd = ["/liferay-tasks-portlet.workflowtask/group-workflow-tasks":["companyId":"5"]]
    
    
    func loadMyTasks(session:LRSession, success:(([WorkflowTask])->Void)?, failure:((NSError)->Void)?=nil) {
        prepareAsyncSession(session, success: success, failure: failure)
        
        var e = NSError?()
        session.invoke(myTasksCmd, error: &e)
    }
    
    func loadGroupTasks(session:LRSession, success:(([WorkflowTask])->Void)?, failure:((NSError)->Void)?=nil) {
        prepareAsyncSession(session, success: success, failure: failure)
        var e = NSError?()
        session.invoke(groupTasksCmd, error: &e)
    }

    func assignMeTask(taskId:Int, session:LRSession, success:(([WorkflowTask])->Void)?, failure:((NSError)->Void)?=nil) {
        let assignMeTaskCmd = ["/liferay-tasks-portlet.workflowtask/assign-me-workflow-task":[
            "companyId":"5",
            "workflowTaskId":"\(taskId)"
        ]]
        
        prepareAsyncSession(session, success: success, failure: failure)
        var e = NSError?()
        session.invoke(assignMeTaskCmd, error: &e)
    }
    
    func completeTask(taskId:Int, transition:String, comment:String, session:LRSession, success:(([WorkflowTask])->Void)?, failure:((NSError)->Void)?=nil) {
        let completeTaskCmd = ["/liferay-tasks-portlet.workflowtask/complete-workflow-task":[
            "companyId": "5",
            "workflowTaskId": "\(taskId)",
            "comment": comment,
            "transition": transition
        ]]
        
        prepareAsyncSession(session, success: success, failure: failure)
        var e = NSError?()
        session.invoke(completeTaskCmd, error: &e)
    }

    func newTasksAfterTimestamp(timestamp: String, session:LRSession, success:(([WorkflowTask])->Void)?, failure:((NSError)->Void)?=nil) {
        
        let completeTaskCmd = ["/liferay-tasks-portlet.workflowtask/new-tasks-after-timestamp":[
            "companyId": "5",
            "timestamp": timestamp
        ]]
        
        prepareAsyncSession(session, success: success, failure: failure)
        var e = NSError?()
        session.invoke(completeTaskCmd, error: &e)
    }
    
    func prepareAsyncSession(session:LRSession, success:(([WorkflowTask])->Void)?, failure:((NSError)->Void)?=nil) {
        session.onSuccess(
            {
                (res:AnyObject!) in
                if let callback = success {
                    var result:[WorkflowTask] = []
                    if (res.isKindOfClass(NSArray)) {
                        let entries:NSArray = res as! NSArray
                        for entry in entries {
                            result.append(self.convert(entry as! NSDictionary))
                        }
                    } else if (res.isKindOfClass(NSDictionary)) {
                        result.append(self.convert(res as! NSDictionary))
                    }
                    callback(result)
                }
            },
            onFailure:
            {
                (e:NSError!) in
                if let fail = failure {
                    fail(e)
                }
            }
        )
    }
    
    private func convert(dict:NSDictionary) -> WorkflowTask {
        let task = WorkflowTask(
            workflowTaskId: (dict["workflowTaskId"] as? NSNumber)!.integerValue,
            title: (dict["title"] as? NSString)! as String,
            description: (dict["description"] as? String)!,
            workflowName: (dict["workflowName"] as? String)!,
            previewURL: (dict["previewUrl"] as? String)!,
            completed: (dict["completed"] as? Bool)!,
            initiator: (dict["initiator"] as? String)!,
            entryType: (dict["entryType"] as? String)!,
            createDate: (dict["createDate"] as? String)!,
            transitions: (dict["transitions"] as? [String])!,
            articleId: (dict["articleId"] as? NSNumber)!.stringValue
        )

        return task
    }
}