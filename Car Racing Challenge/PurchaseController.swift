//
//  PurchaseController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 27/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation

private var _instance : PurchaseController!;

class PurchaseController
{
    class func getInstance() -> PurchaseController
    {
        if(_instance == nil)
        {
            _instance = PurchaseController();
        }
        
        return _instance;
    }
    
    func hasPurchased() -> Bool
    {
        return false;
    }
}