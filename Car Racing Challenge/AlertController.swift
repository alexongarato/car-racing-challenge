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
    fileprivate var _alert:AlertView!;
    fileprivate var _controller:UIViewController!;
    
    class func getInstance() -> AlertController
    {
        if(_instance == nil)
        {
            _instance = AlertController();
        }
        return _instance;
    }
    
    func build(_ controller:UIViewController)
    {
        _controller = controller;
    }
    
    func showAlert(_ title:String! = nil, message:String! = nil, action:String! = nil, completion:(()->Void)! = nil)
    {
        func block()
        {
            _alert = AlertView(title: title, message: message, action: action, completion: completion);
            _controller.view.addSubview(_alert);
        }
        
        self.hideAlert(block);
    }
    
    func hideAlert(_ completion:(()->Void)!)
    {
        
        if(_alert != nil)
        {
            func end(_ animated:Bool)
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
        fileprivate var curTitle    : String!;
        fileprivate var message     : String!;
        fileprivate var action      : String!;
        fileprivate var completion  : (()->Void)!;
        fileprivate var bg          : UIView!;
        
        convenience init(title:String!, message:String!, action:String!, completion:(()->Void)!)
        {
            self.init();
            self.curTitle = title;
            self.message = message;
            self.action = action;
            self.completion = completion;
            
            self.backgroundColor = UIColor.black.alpha(0.7);
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
            
            func newField(_ text:String, isAction:Bool = false)
            {
                let field = UITextView();
                field.isScrollEnabled = false;
                field.isEditable = false;
                field.isSelectable = false;
                field.text = text;
                field.textAlignment = NSTextAlignment.center;
                field.sizeToFit();
                field.font = isAction ? Fonts.BoldFont(FontSize.Default) : Fonts.LightFont(FontSize.Default);
                field.textColor = UIColor.black;
                field.backgroundColor = UIColor.clear;
                bg.addSubview(field);
                field.y = currHeight;
                field.width = bg.width - 20;
                currHeight = field.y + field.height;
                
                if(isAction)
                {
                    field.addTarget(self, selector: Selector(completion != nil ? "completionHandler" : "closeHandler"));
                    field.width = bg.width;
                    field.height = 35;
                    let border:CALayer = CALayer();
                    border.frame = CGRect(x: 5, y: 0, width: field.width-10, height: 1);
                    border.backgroundColor = UIColor.black.alpha(0.2).cgColor;
                    field.layer.addSublayer(border);
                    field.backgroundColor = UIColor.white.alpha(0.1);
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
            if(UICustomDevice.avoidTexture())
            {
                bg.backgroundColor = Colors.green;
            }
            else
            {
                bg.backgroundColor = UIColor(patternImage: ImageHelper.imageWithName(ImagesNames.Background));
            }
            
            bg.center = self.center;
            self.addSubview(bg);
            
            UIView.animate(withDuration: AnimationTime.Fast, animations: {
                self.alpha = 1;
            });
            
            self.bg.alpha = 0;
            self.bg.layer.transform = CATransform3DMakeRotation(10, 0, self.height, 1);
            UIView.animate(withDuration: AnimationTime.Fast,
                delay:AnimationTime.Fast,
                options:UIViewAnimationOptions(), animations: {
                self.bg.alpha = 1;
                self.bg.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
                }, completion: { (animate) -> Void in
                    if(self.action == nil && self.completion != nil)
                    {
                        self.completion();
                    }
            });
            
        }
        
        func hide(_ callback:((_ animated:Bool)->Void)!)
        {
            UIView.animate(withDuration: AnimationTime.Fast,
                delay:0,
                options:UIViewAnimationOptions(), animations: {
                    self.bg.alpha = 0;
                    self.bg.layer.transform = CATransform3DMakeRotation(10, 0, self.height, 1);
                }, completion: {(animated) -> Void in
                    
                    UIView.animate(withDuration: AnimationTime.Fast,
                        delay:0,
                        options:UIViewAnimationOptions(), animations: {
                            self.bg.alpha = 0;
                        }, completion: callback);
            });
        }
    }
}
