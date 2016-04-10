//
//  AsyncHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 15/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
private var _asynHelperWorkQueue:NSOperationQueue = NSOperationQueue();

class AsyncHelper
{
    class func addWorkBlock(block:dispatch_block_t!)
    {
        _asynHelperWorkQueue.addOperationWithBlock(block);
    }
    
    class func addMainBlock(block:dispatch_block_t!)
    {
        NSOperationQueue.mainQueue().addOperationWithBlock(block);
    }
}