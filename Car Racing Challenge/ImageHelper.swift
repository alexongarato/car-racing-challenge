//
//  ImageHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 3/25/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit


struct ImagesNames
{
    static var PixelOn                  : String = "PixelOn";
    static var PixelOff                 : String = "PixelOff";
    static var Background               : String = "Background";
    static var MenuBackground           : String = "MenuBG";
    static var MenuBackgroundiPhone6    : String = "MenuBG_iphone6";
    static var Podium                   : String = "Podium";
    static var Instructions             : String = "Instructions.png";
    static var ConfigIcon               : String = "ConfigIcon.png";
    static var AppIcon                  : String = "AppIcon";
    static var AlertBG                  : String = "Alert.png";
    static var TouchAreas               : String = "TouchAreas.png";
    static var FBIcon                   : String = "FBIcon";
    static var TTIcon                   : String = "TTIcon";
}


class ImageHelper
{
    class func imageWithName(_ name:String) -> UIImage!
    {
        return UIImage(named: name);
    }
    
    static func imageWithImage(_ image:UIImage!) -> UIImage
    {
        return ImageHelper.resizeImage(image, scale: 0.5);
    }
    
    static func imageScaledWithImage(_ image:UIImage!, fitToWidth:CGFloat) -> UIImage
    {
        let scale:CGFloat = fitToWidth / image.size.width;
        return ImageHelper.resizeImage(image, scale: scale);
    }
    
    static func imageScaledToFit(_ image:UIImage!, sizeToFit:CGSize) -> UIImage
    {
        let scale:CGFloat = (image.size.width > image.size.height || (sizeToFit.width < sizeToFit.height && image.size.width >= image.size.height)) ? sizeToFit.width / image.size.width : sizeToFit.height / image.size.height;
        return ImageHelper.resizeImage(image, scale: scale);
    }
    
    static func imageScaledToFill(_ image:UIImage!, sizeToFill:CGSize) -> UIImage
    {
        let scale:CGFloat = (image.size.width < image.size.height || (sizeToFill.width > sizeToFill.height && image.size.width <= image.size.height)) ? sizeToFill.width / image.size.width : sizeToFill.height / image.size.height;
        return ImageHelper.resizeImage(image, scale: scale);
    }
    
    static func resizeImage(_ image:UIImage!, scale:CGFloat) -> UIImage
    {
        let newSize:CGSize = CGSize(width: Int(image.size.width * scale), height: Int(image.size.height * scale));
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

