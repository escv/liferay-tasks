//
//  WorkflowTask.swift
//  liferay-tasks
//
//  Created by Andre Albert on 02.03.15.
//  Copyright (c) 2015 PD. All rights reserved.
//

import Foundation

/**
* Model definition which conforms to the JSON exchange data
**/
struct WorkflowTask {

    var workflowTaskId:Int
    
    var title: String
    
    var description: String
    
    var workflowName: String
    
    var previewURL: String
    
    var completed: Bool
    
    var initiator: String
    
    var entryType: String
    
    var createDate: String
    
    var transitions: [String]
    
    var articleId: String

}