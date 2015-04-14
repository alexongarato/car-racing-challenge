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
    
    func showAlert(title:String! = nil, message:String! = nil, action:String! = "OK", cancel:String! = nil, completion:(()->Void)! = nil)
    {
        func block()
        {
            _alert = AlertView(title: title, message: message, action: action, cancel: cancel, completion: completion);
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
                self._alert.removeFromSuperview();
                self._alert = nil;
                completion();
            }
            UIView.animateWithDuration(AnimationTime.Fast, animations: {
                self._alert.alpha = 0;
                }, completion: end);
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
        private var title       : String!;
        private var message     : String!;
        private var action      : String!;
        private var cancel      : String!;
        private var completion  : (()->Void)!;
        
        private var bg          : UIImageView!;
        
        convenience init(title:String!, message:String!, action:String!, cancel:String!, completion:(()->Void)!)
        {
            self.init();
            self.title = title;
            self.message = message;
            self.action = action;
            self.cancel = cancel;
            self.completion = completion;
            
            self.backgroundColor = UIColor.blackColor().alpha(0.5);
            
            
        }
        
        override func didMoveToSuperview()
        {
            super.didMoveToSuperview();
            
            var img:UIImage = ImageHelper.imageWithName(ImagesNames.AlertBG);
            bg = UIImageView(image: ImageHelper.imageScaledToFit(img, sizeToFit: self.frame.size));
            self.addSubview(bg);
        }
    }
}