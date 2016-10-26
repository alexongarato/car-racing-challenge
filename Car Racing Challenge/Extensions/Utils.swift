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

@available(iOS 8.0, *)
private var _alert:UIAlertController!;
private var _alertView:UIAlertView!;

class Utils
{
    class func vibrate()
    {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
    }
    
    class func random(_ i:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(1+i)));
    }
    
    class func delayedCall(_ interval:TimeInterval, target:AnyObject, selector:Selector, repeats:Bool) -> Timer
    {
        return Timer.scheduledTimer(timeInterval: interval, target: target, selector: selector, userInfo: nil, repeats: repeats);
    }
    
    class func createCarTexture(_ size:CGSize, pixelWidth:CGFloat, pixelHeight:CGFloat) -> SKTexture
    {
        //var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight);
        let pixelOn:CGImage = UIImage(named:ImagesNames.PixelOn)!.cgImage!;
        
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
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        for i in 0 ..< pixelVect.count
        {
            if(pixelVect[i].active)
            {
                let pnt:CGPoint = CGPoint(x: pixelVect[i].x, y:pixelVect[i].y);
                let rect:CGRect = CGRect(origin: pnt, size: CGSize(width: pixelWidth, height: pixelHeight));
                context.draw(pixelOn, in: rect);
            }
        }
        let tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let tempTexture:SKTexture = SKTexture(cgImage: tiledPixels.cgImage!);
        tempTexture.filteringMode = SKTextureFilteringMode.nearest;
//        tempTexture.usesMipmaps = true;
        
        return tempTexture;
    }
    
    class func createPixelsGrid(_ size:CGSize, totalPixelsX:Int, totalPixelsY:Int, pixelSize:CGFloat) -> SKTexture
    {
//        var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize);
        let pixelOff:CGImage = UIImage(named:ImagesNames.PixelOff)!.cgImage!;
        
        UIGraphicsBeginImageContext(size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        
        for x in 0 ..< totalPixelsX
        {
            for y in 0 ..< totalPixelsY
            {
                let pnt:CGPoint = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                let rect:CGRect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                context.draw(pixelOff, in: rect);
            }
        }
        
        let tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let tempTexture:SKTexture = SKTexture(cgImage: tiledPixels.cgImage!);
        tempTexture.filteringMode = SKTextureFilteringMode.nearest;
        
        return tempTexture;
    }
    
    class func createRoadPixels(_ size:CGSize, totalPixelsX:Int, totalPixelsY:Int, pixelSize:CGFloat) -> SKTexture
    {
        //var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize);
        let pixelOn:CGImage = UIImage(named:ImagesNames.PixelOn)!.cgImage!;
        
        UIGraphicsBeginImageContext(size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        var pnt:CGPoint!;
        var rect:CGRect!;
        for x in stride(from: 0, to: totalPixelsX, by: totalPixelsX-1)
        {
            for var y in 0 ..< totalPixelsY
            {
                pnt = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                rect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                context.draw(pixelOn, in: rect);
                
                y += 1;
                
                pnt = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                rect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                context.draw(pixelOn, in: rect);
                
                y += 1;
                
                pnt = CGPoint(x: pixelSize * x.floatValue, y:pixelSize * y.floatValue);
                rect = CGRect(origin: pnt, size: CGSize(width: pixelSize, height: pixelSize));
                context.draw(pixelOn, in: rect);
                
                y += 1;
                
            }
        }
        
        let tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let tempTexture:SKTexture = SKTexture(cgImage: tiledPixels.cgImage!);
        tempTexture.filteringMode = SKTextureFilteringMode.nearest;
        
        return tempTexture;
    }
    
    class func printFontNames()
    {
//        #if DEBUG
        for family:String in UIFont.familyNames
        {
            print("Font family: \(family)");
            
            for name:String in UIFont.fontNames(forFamilyName: family)
            {
                print("  - Font name: \(name)");
            }
        }
//        #endif
    }
}

