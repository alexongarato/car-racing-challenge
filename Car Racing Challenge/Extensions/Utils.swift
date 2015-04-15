//
//  Utils.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 17/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import AudioToolbox

private var _alert:UIAlertController!;
private var _alertView:UIAlertView!;

class Utils
{
    class func vibrate()
    {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
    }
    
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
        var pixelOn:CGImageRef = UIImage(named:ImagesNames.PixelOn)!.CGImage;
        
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
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        
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
        
        var tempTexture:SKTexture = SKTexture(CGImage: tiledPixels.CGImage);
        tempTexture.filteringMode = SKTextureFilteringMode.Nearest;
//        tempTexture.usesMipmaps = true;
        
        return tempTexture;
    }
    
    class func createPixelsGrid(size:CGSize, totalPixelsX:Int, totalPixelsY:Int, pixelSize:CGFloat) -> SKTexture
    {
        var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize);
        var pixelOff:CGImageRef = UIImage(named:ImagesNames.PixelOff)!.CGImage;
        
        UIGraphicsBeginImageContext(size);
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        
        for(var x:Int = 0; x < totalPixelsX; x++)
        {
            for(var y:Int = 0; y <= totalPixelsY; y++)
            {
                var pnt:CGPoint = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                var rect:CGRect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                CGContextDrawImage(context, rect, pixelOff);
            }
        }
        
        var tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        var tempTexture:SKTexture = SKTexture(CGImage: tiledPixels.CGImage);
        tempTexture.filteringMode = SKTextureFilteringMode.Nearest;
        
        return tempTexture;
    }
    
    class func createRoadPixels(size:CGSize, totalPixelsX:Int, totalPixelsY:Int, pixelSize:CGFloat) -> SKTexture
    {
        var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize);
        var pixelOn:CGImageRef = UIImage(named:ImagesNames.PixelOn)!.CGImage;
        
        UIGraphicsBeginImageContext(size);
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        var pnt:CGPoint!;
        var rect:CGRect!;
        for(var x:Int = 0; x < totalPixelsX; x += totalPixelsX - 1)
        {
            for(var y:Int = 0; y < totalPixelsY; y++)
            {
                
                pnt = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                rect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                CGContextDrawImage(context, rect, pixelOn);
                
                y++;
                
                pnt = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                rect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                CGContextDrawImage(context, rect, pixelOn);
                
                y++;
                
                pnt = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                rect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                CGContextDrawImage(context, rect, pixelOn);
                
                y++;
                
            }
        }
        
        var tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        var tempTexture:SKTexture = SKTexture(CGImage: tiledPixels.CGImage);
        tempTexture.filteringMode = SKTextureFilteringMode.Nearest;
        
        return tempTexture;
    }
    
    class func printFontNames()
    {
//        #if DEBUG
        for family:AnyObject in UIFont.familyNames()
        {
            Trace("Font family: \(family as? String)");
            
            for name:AnyObject in UIFont.fontNamesForFamilyName(family as! String)
            {
                Trace("  - Font name: \(name as! String)");
            }
        }
//        #endif
    }
}

