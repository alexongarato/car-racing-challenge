//
//  Extensions.swift
//  Boticario.Mobile
//
//  Created by Alex Ongarato on 12/3/14.
//  Copyright (c) 2014 ___w3haus___. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
//
extension SKSpriteNode
{
    
}
//    func addTarget(target:AnyObject, selector:Selector)
//    {
//        var gestureRec:UITapGestureRecognizer = UITapGestureRecognizer(target: target, action: selector);
//        self.userInteractionEnabled = true;
//        self.tou
//        self.addGestureRecognizer(gestureRec);
//    }
//}

extension CGSize
{
    var description: NSString { get { return "CGSize(width:\(self.width), height:\(self.height))";} };
}

extension CGFloat
{
    var half: CGFloat { get { return self * 0.5; } };
}
