//
//  SocialController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import Social
import Twitter
import Accounts

private var _instance:SocialController!;

class SocialController
{
    static var twitterType:String = SLServiceTypeTwitter;
    static var facebookType:String = SLServiceTypeFacebook;
    private var _isTwitterAvailable:Bool = false;
    private var _isFacebookAvailable:Bool = false;
    
    class func getInstance() -> SocialController
    {
        if(_instance == nil)
        {
            _instance = SocialController();
        }
        
        return _instance;
    }
    
    func didFinishLaunchingWithOptions()
    {
        if let sheet:SLComposeViewController! = SLComposeViewController(forServiceType: SocialController.twitterType)
        {
            _isTwitterAvailable = true;
        }
        
        if let sheet:SLComposeViewController! = SLComposeViewController(forServiceType: SocialController.facebookType)
        {
            _isFacebookAvailable = true;
        }
    }
    
    func isTwitterAvailable() -> Bool
    {
        return _isTwitterAvailable;
    }
    
    func isFacebookAvailable() -> Bool
    {
        return _isFacebookAvailable;
    }
    
    func share(type:String, text:String, url:String! = nil, image:UIImage! = nil)
    {
        var error:Bool = false;
        if(SLComposeViewController.isAvailableForServiceType(type))
        {
            if let sheet:SLComposeViewController! = SLComposeViewController(forServiceType: type)
            {
                sheet.setInitialText(text);
                
                if(url != nil)
                {
                    sheet.addURL(NSURL(string: url));
                }
                
                if(image != nil)
                {
                    sheet.addImage(image);
                }
                
                AppDelegate.getInstance().gameController.presentViewController(sheet, animated: true, completion: nil);
            }
            else
            {
                 error = true;
            }
        }
        else
        {
            error = true;
        }
        
        if(error)
        {
            Trace("share error");
            var source:String = (type == SLServiceTypeTwitter) ? "Twitter" : "Facebook";
            AlertController.getInstance().showAlert(title: "Accounts", message: "Please login to a \(source) account to share.", action: nil, cancel: "OK", completion: nil);
        }
    }
}