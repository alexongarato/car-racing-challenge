//
//  AsyncHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 15/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
private var _asynHelperWorkQueue:OperationQueue = OperationQueue();

class AsyncHelper
{
    class func addWorkBlock(_ block:@escaping () -> Void)
    {
        _asynHelperWorkQueue.addOperation(block);
    }
    
    class func addMainBlock(_ block:@escaping () -> Void)
    {
        OperationQueue.main.addOperation(block);
    }
}
