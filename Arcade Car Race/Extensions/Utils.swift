//
//  Utils.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 17/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Utils
{
    class func random(i:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(1+i)));
    }
    
    class func delayedCall(interval:NSTimeInterval, target:AnyObject, selector:Selector, repeats:Bool) -> NSTimer
    {
        return NSTimer.scheduledTimerWithTimeInterval(interval, target: target, selector: selector, userInfo: nil, repeats: repeats);
    }
    
    class func createCarTexture(size:CGSize, pixelWidth:CGFloat, pixelHeight:CGFloat) -> SKTexture
    {
        var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight);
        var pixelOn:CGImageRef = UIImage(named:"PixelOn")!.CGImage;
        
        var pixelVect:Array<Pixel> = Array<Pixel>();
        pixelVect.append(Pixel(x: 0,                y: 0,                active: false));
        pixelVect.append(Pixel(x: pixelWidth,       y: 0,                active: true));
        pixelVect.append(Pixel(x: pixelWidth * 2,   y: 0,                active: false));
        
        pixelVect.append(Pixel(x: 0,                y: pixelHeight,      active: true));
        pixelVect.append(Pixel(x: pixelWidth,       y: pixelHeight,      active: true));
        pixelVect.append(Pixel(x: pixelWidth * 2,   y: pixelHeight,      active: true));
        
        pixelVect.append(Pixel(x: 0,                y: pixelHeight * 2,  active: false));
        pixelVect.append(Pixel(x: pixelWidth,       y: pixelHeight * 2,  active: true));
        pixelVect.append(Pixel(x: pixelWidth * 2,   y: pixelHeight * 2,  active: false));
        
        pixelVect.append(Pixel(x: 0,                y: pixelHeight * 3,  active: true));
        pixelVect.append(Pixel(x: pixelWidth,       y: pixelHeight * 3,  active: false));
        pixelVect.append(Pixel(x: pixelWidth * 2,   y: pixelHeight * 3,  active: true));
        
        UIGraphicsBeginImageContext(size);
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        for(var i:Int = 0; i < pixelVect.count; i++)
        {
            if(pixelVect[i].active)
            {
                var pnt:CGPoint = CGPoint(x: pixelVect[i].x, y:pixelVect[i].y);
                var rect:CGRect = CGRect(origin: pnt, size: CGSize(width: pixelWidth, height: pixelHeight));
                CGContextDrawImage(context, rect, pixelOn);
            }
        }
        var tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return SKTexture(CGImage: tiledPixels.CGImage);
    }
}

