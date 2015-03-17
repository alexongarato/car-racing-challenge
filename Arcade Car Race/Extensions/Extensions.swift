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

extension SKNode
{
    var x:CGFloat{get{return self.position.x;} set(value){self.position.x = value;}};
    var y:CGFloat{get{return self.position.y;} set(value){self.position.y = value;}};
}

extension SKSpriteNode
{
    var height:CGFloat{get{return self.size.height;} set(value){self.size.height = value;}};
    var width:CGFloat{get{return self.size.width;} set(value){self.size.width = value;}};
}

extension SKScene
{
    var height:CGFloat{get{return self.size.height;} set(value){self.size.height = value;}};
    var width:CGFloat{get{return self.size.width;} set(value){self.size.width = value;}};
}

extension CGSize
{
    var description: NSString { get { return "CGSize(width:\(self.width), height:\(self.height))";} };
}

extension CGFloat
{
    var half: CGFloat { get { return self * 0.5; } };
    var intValue: Int { get { return Int(self); } };
    var roundValue: CGFloat { get { return CGFloat(Int(self)); } };
}

extension Int
{
    var floatValue: CGFloat { get { return CGFloat(self); } };
}

//utils

extension UIImage
{
    var height:CGFloat{get{return self.size.height;}};
    var width:CGFloat{get{return self.size.width;}};
    
    func imageWithHalfSize() -> UIImage
    {
        return self.resizeImage(scale: 0.5);
    }
    
    func imageScaled(#fitToWidth:CGFloat) -> UIImage
    {
        var scale:CGFloat = fitToWidth / self.width;
        return self.resizeImage(scale: scale);
    }
    
    func imageScaledToFit(#sizeToFit:CGSize) -> UIImage
    {
        var scale:CGFloat = (self.width > self.height || (sizeToFit.width < sizeToFit.height && self.width >= self.height))
            ? sizeToFit.width / self.width
            : sizeToFit.height / self.height;
        return self.resizeImage(scale: scale);
    }
    
    func imageScaledToFill(#sizeToFill:CGSize) -> UIImage
    {
        var scale:CGFloat = (self.width < self.height || (sizeToFill.width > sizeToFill.height && self.width <= self.height))
            ? sizeToFill.width / self.width
            : sizeToFill.height / self.height;
        return self.resizeImage(scale: scale);
    }
    
    func resizeImage(#scale:CGFloat) -> UIImage
    {
        var newSize:CGSize = CGSize(width: Int(self.width * scale), height: Int(self.height * scale));
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
        var newImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}
