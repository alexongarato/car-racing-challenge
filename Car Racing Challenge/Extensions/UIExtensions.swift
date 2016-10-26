//
//  UIExtensions.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    var height:CGFloat{get{return self.size.height;}};
    var width:CGFloat{get{return self.size.width;}};
    
    func imageWithHalfSize() -> UIImage
    {
        return self.resizeImage(0.5);
    }
    
    func imageScaled(_ fitToWidth:CGFloat) -> UIImage
    {
        let scale:CGFloat = fitToWidth / self.width;
        return self.resizeImage(scale);
    }
    
    func imageScaledToFit(_ sizeToFit:CGSize) -> UIImage
    {
        let scale:CGFloat = (self.width > self.height || (sizeToFit.width < sizeToFit.height && self.width >= self.height))
            ? sizeToFit.width / self.width
            : sizeToFit.height / self.height;
        return self.resizeImage(scale);
    }
    
    func imageScaledToFill(_ sizeToFill:CGSize) -> UIImage
    {
        let scale:CGFloat = (self.width < self.height || (sizeToFill.width > sizeToFill.height && self.width <= self.height))
            ? sizeToFill.width / self.width
            : sizeToFill.height / self.height;
        return self.resizeImage(scale);
    }
    
    func resizeImage(_ scale:CGFloat) -> UIImage
    {
        let newSize:CGSize = CGSize(width: Int(self.width * scale), height: Int(self.height * scale));
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

class AbstractView:UIView
{
    var animationStyle:AnimationStyle = AnimationStyle.slideUp;
    fileprivate var _callback:(()->Void)!;
    
    override func didMoveToSuperview()
    {
        self.inflate(false);
        
        if(self.animationStyle == .scale)
        {
            self.alpha = 0;
        }
    }
    
    func present(_ completion:((_ animated:Bool)->Void)!)
    {
        var vel:TimeInterval = 0;
        if(self.animationStyle == .scale)
        {
            self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
            vel = AnimationTime.Fast;
        }
        else if(self.animationStyle == .slideUp)
        {
            self.y = self.height;
            vel = AnimationTime.Slow;
        }
        
        UIView.animate(withDuration: vel, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            if(self.animationStyle == .scale)
            {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1);
                self.alpha = 1;
            }
            else if(self.animationStyle == .slideUp)
            {
                self.y = 0;
            }
        }, completion: completion);
    }
    
    func dismiss(_ completion:((_ animated:Bool)->Void)!)
    {
        var vel:TimeInterval = 0;
        if(self.animationStyle == .scale)
        {
            vel = AnimationTime.Fast;
        }
        else if(self.animationStyle == .slideUp)
        {
            vel = AnimationTime.Slow;
        }
        
        UIView.animate(withDuration: vel, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            if(self.animationStyle == .scale)
            {
                self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
                self.alpha = 0;
            }
            else if(self.animationStyle == .slideUp)
            {
                self.y = self.height;
            }
        }, completion: completion);
    }
}

extension UIView
{
    var y               : CGFloat{ get { return self.frame.origin.y;   } set(val) { self.frame.origin.y = val; } };
    var x               : CGFloat{ get { return self.frame.origin.x;   } set(val) { self.frame.origin.x = val; } };
    var height          : CGFloat{ get { return self.frame.height;     } set(val) { self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: val); } };
    var width           : CGFloat{ get { return self.frame.width;      } set(val) { self.frame = CGRect(x: self.x, y: self.y, width: val, height: self.height); } };
    
    /**
    Auto inflate only the with property and optionaly propagate the changes to superviews recursively.
    */
    func inflate(_ propagate:Bool)
    {
        inflate(width: -1, height: -1, propagate: propagate);
    }
    
    /**
    Auto Inflate the with property, set the new height property and optionaly propagate the changes to superviews recursively.
    
    @height the desired height or -1 to use the current frame height.
    */
    func inflate(height newHeight:CGFloat, propagate:Bool)
    {
        inflate(width: -1, height: newHeight, propagate: propagate);
    }
    
    /**
    Inflate the with and height properties with the given values and optionaly propagate the changes to superviews recursively.
    
    @width the desired width or -1 to use its superview width property.
    
    @height the desired height or -1 to use the current frame height.
    */
    func inflate(width newWidth:CGFloat, height newHeight:CGFloat, propagate:Bool)
    {
        if(self.superview != nil)
        {
            self.frame = CGRect(x: self.x,
                y: self.y,
                width: newWidth == -1 ? self.width == 0 ? self.superview!.frame.width : self.width : newWidth,
                height: newHeight == -1 ? self.height == 0 ? self.superview!.frame.height : self.height : newHeight);
            
            if(!propagate)
            {
                return;
            }
            
            let superFrame:CGRect = self.superview!.frame;
            
            if(self.y + newHeight + 90 >= superFrame.height)
            {
                if(self.superview!.isKind(of: UIScrollView.self))
                {
                    //print("inflate -> reached the scrollview");
                    
                    let scroll:UIScrollView = self.superview as! UIScrollView;
                    scroll.contentSize = CGSize(width: scroll.frame.width, height: self.y + newHeight + 30);
                }
                else
                {
                    //print("inflate -> propagating (superview:\(self.superview!.description))");
                    
                    self.superview!.inflate(height: self.y + self.frame.height, propagate: true);
                }
            }
        }
        else
        {
            self.frame = CGRect(x: self.x, y: self.y, width: newWidth, height: newHeight);
        }
    }
    
    func addTarget(_ target:AnyObject, selector:Selector)
    {
        self.isUserInteractionEnabled = true;
        self.addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector));
    }
    
    func onTouchAnima()
    {
        func completion1(_ animated:Bool)
        {
            UIView.animate(withDuration: AnimationTime.VeryFast, delay:0, options:UIViewAnimationOptions.curveEaseIn, animations: {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1);
                }, completion: nil);
        }
        
        UIView.animate(withDuration: AnimationTime.VeryFast, delay:0, options:UIViewAnimationOptions.curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
            }, completion: completion1);
    }
    
    func removeTargets()
    {
        self.gestureRecognizers?.removeAll(keepingCapacity: false);
    }
    
    @available(iOS 8.0, *)
    func enableBlur(_ style:UIBlurEffectStyle)
    {
        //only apply the blur if the user hasn't disabled transparency effects
        if(!UICustomDevice.isIOS8OrHigher())
        {
            self.backgroundColor = UIColor.white.alpha(0.9);
            return;
        }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style)) as UIVisualEffectView;
        visualEffectView.frame = self.bounds;
        self.addSubview(visualEffectView)
        visualEffectView.alpha = 0.9;
    }
    
    func enableGaussianBlur()
    {
        if(!UICustomDevice.isIOS8OrHigher())
        {
            self.backgroundColor = UIColor.black.alpha(0.9);
            return;
        }
        
        if !UIAccessibilityIsReduceTransparencyEnabled()
        {
            
        }
        else
        {
            self.backgroundColor = UIColor.black.alpha(0.9);
        }
        
    }
    
    func scale(_ value:CGFloat)
    {
        self.layer.transform = CATransform3DMakeScale(value, value, 1);
//        self.width = self.width * value;
//        self.height = self.height * value;
    }
    
    func removeAllSubviews()
    {
        for view in self.subviews
        {
            view.removeFromSuperview();
        }
    }
    
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIColor
{
    func alpha(_ val:CGFloat) -> UIColor
    {
        return self.withAlphaComponent(val);
    }
    
    var HEXColor : NSString {
        get {
            var str:NSString = "";
            
            let numComponents:Int = self.cgColor.numberOfComponents;
            
            if (numComponents == 4)
            {
                let components = self.cgColor.components;
                str = NSString(format:"#%2X%2X%2X", Int((components?[0])! * 255), Int((components?[1])! * 255), Int((components?[2])! * 255));
                str = str.replacingOccurrences(of: " ", with: "0") as NSString;
            }
            
            return str;
        }
    }
}

extension CGSize
{
    var description : NSString { get { return "CGSize(width:\(self.width), height:\(self.height))" as NSString; } };
    var doubleValue : CGSize { get { return CGSize(width: self.width * 2, height: self.height * 2); } };
    var halfValue   : CGSize { get { return CGSize(width: self.width * 0.5, height: self.height * 0.5); } };
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

extension UILabel
{
    func bold(_ word:String)
    {
        self.bold(word, color: self.textColor);
    }
    
    func bold(_ word:String, color:UIColor!)
    {
        let temp:NSMutableAttributedString = self.attributedText as! NSMutableAttributedString;
        let main_string:NSString = temp.string as NSString;
        let range:NSRange = (main_string as NSString).range(of: word);
        if(range.length > 0)
        {
            let format:NSDictionary = [NSFontAttributeName : Fonts.BoldFont(self.font.pointSize), NSForegroundColorAttributeName: color];
            temp.addAttributes(format as! [String : AnyObject], range: (main_string as NSString).range(of: word));
            self.attributedText = temp;
        }
    }
}

