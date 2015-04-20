//
//  AlertController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 13/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

private var _instance:AlertController!;

class AlertController
{
    private var _alert:AlertView!;
    private var _controller:UIViewController!;
    
    class func getInstance() -> AlertController
    {
        if(_instance == nil)
        {
            _instance = AlertController();
        }
        return _instance;
    }
    
    func build(controller:UIViewController)
    {
        _controller = controller;
    }
    
    func showAlert(title:String! = nil, message:String! = nil, action:String! = nil, completion:(()->Void)! = nil)
    {
        func block()
        {
            _alert = AlertView(title: title, message: message, action: action, completion: completion);
            _controller.view.addSubview(_alert);
        }
        
        self.hideAlert(block);
    }
    
    func hideAlert(completion:(()->Void)!)
    {
        
        if(_alert != nil)
        {
            func end(animated:Bool)
            {
                if(_alert != nil)
                {
                    if(self._alert.superview != nil)
                    {
                        self._alert.removeFromSuperview();
                    }
                    self._alert = nil;
                }
                if(completion != nil)
                {
                    completion();
                }
            }
            
            _alert.hide(end);
        }
        else
        {
            if(completion != nil)
            {
                completion();
            }
        }
    }
    
    class AlertView:AbstractView
    {
        private var curTitle    : String!;
        private var message     : String!;
        private var action      : String!;
        private var completion  : (()->Void)!;
        private var bg          : UIView!;
        
        convenience init(title:String!, message:String!, action:String!, completion:(()->Void)!)
        {
            self.init();
            self.curTitle = title;
            self.message = message;
            self.action = action;
            self.completion = completion;
            
            self.backgroundColor = UIColor.blackColor().alpha(0.7);
        }
        
        func closeHandler()
        {
            AlertController.getInstance().hideAlert(nil);
        }
        
        func completionHandler()
        {
            self.completion();
        }
        
        override func didMoveToSuperview()
        {
            super.didMoveToSuperview();
            
            self.alpha = 0;
            
            var currHeight:CGFloat = 10;
            bg = UIView();
            bg.layer.masksToBounds = true;
            bg.frame.size = CGSize(width: 200, height: currHeight);
            
            func newField(text:String, isAction:Bool = false)
            {
                var field = UITextView();
                field.scrollEnabled = false;
                field.editable = false;
                field.selectable = false;
                field.text = text;
                field.textAlignment = NSTextAlignment.Center;
                field.sizeToFit();
                field.font = isAction ? Fonts.BoldFont(FontSize.Default) : Fonts.LightFont(FontSize.Default);
                field.textColor = UIColor.blackColor();
                field.backgroundColor = UIColor.clearColor();
                bg.addSubview(field);
                field.y = currHeight;
                field.width = bg.width - 20;
                currHeight = field.y + field.height;
                
                if(isAction)
                {
                    field.addTarget(self, selector: Selector(completion != nil ? "completionHandler" : "closeHandler"));
                    field.width = bg.width;
                    field.height = 35;
                    var border:CALayer = CALayer();
                    border.frame = CGRectMake(5, 0, field.width-10, 1);
                    border.backgroundColor = UIColor.blackColor().alpha(0.2).CGColor;
                    field.layer.addSublayer(border);
                    field.backgroundColor = UIColor.whiteColor().alpha(0.1);
                }
                else
                {
                    field.sizeToFit();
                    field.width = bg.width - 20;
                    field.x = 10;
                    currHeight = field.y + field.height;
                }
            }
            
            if(self.curTitle != nil)
            {
                newField(self.curTitle);
                
            }
            
            if(self.message != nil)
            {
                newField(self.message);
            }
            
            if(self.action != nil)
            {
                currHeight += 8;
                newField(self.action, isAction:true);
                currHeight -= 5;
            }
            
            
            //----------
            currHeight += 10;
            bg.height = currHeight;
            bg.layer.cornerRadius = 5;
            bg.backgroundColor = UIColor(patternImage: ImageHelper.imageWithName(ImagesNames.Background));
            bg.center = self.center;
            self.addSubview(bg);
            
            UIView.animateWithDuration(AnimationTime.Fast, animations: {
                self.alpha = 1;
            });
            
            self.bg.alpha = 0;
            self.bg.layer.transform = CATransform3DMakeRotation(180, 0, self.height, 1);
            UIView.animateWithDuration(AnimationTime.Fast,
                delay:AnimationTime.Fast,
                options:UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.bg.alpha = 1;
                self.bg.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
                }, completion: { (animate) -> Void in
                    if(self.action == nil && self.completion != nil)
                    {
                        self.completion();
                    }
            });
            
        }
        
        func hide(callback:((animated:Bool)->Void)!)
        {
            UIView.animateWithDuration(AnimationTime.Fast,
                delay:0,
                options:UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.bg.alpha = 0;
                    self.bg.layer.transform = CATransform3DMakeRotation(180, 0, self.height, 1);
                }, completion: {(animated) -> Void in
                    
                    UIView.animateWithDuration(AnimationTime.Fast,
                        delay:0,
                        options:UIViewAnimationOptions.CurveEaseInOut, animations: {
                            self.bg.alpha = 0;
                        }, completion: callback);
            });
        }
    }
}