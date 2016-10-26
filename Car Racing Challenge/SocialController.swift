//
//  SocialController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import Social
import Accounts
import UIKit

private var _instance:SocialController!;

class SocialController
{
    static var twitterType:String = SLServiceTypeTwitter;
    static var facebookType:String = SLServiceTypeFacebook;
    fileprivate var _isTwitterAvailable:Bool = false;
    fileprivate var _isFacebookAvailable:Bool = false;
    var _currentScreenShot:UIImage!;
    
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
        if let _:SLComposeViewController? = SLComposeViewController(forServiceType: SocialController.twitterType)
        {
            _isTwitterAvailable = true;
        }
        
        if let _:SLComposeViewController? = SLComposeViewController(forServiceType: SocialController.facebookType)
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
    
    func share(_ type:String, text:String, url:String! = nil, image:UIImage! = nil)
    {
        AlertController.getInstance().showAlert(message: "loading...");
        
        var error:Bool = false;
        if(SLComposeViewController.isAvailable(forServiceType: type))
        {
            if let sheet:SLComposeViewController? = SLComposeViewController(forServiceType: type)
            {
                sheet?.setInitialText(text);
                
                if(image == nil && self._currentScreenShot != nil)
                {
                    sheet?.add(self._currentScreenShot);
                    if(url != nil)
                    {
                        sheet?.setInitialText("\(text) \(url)");
                    }
                }
                else
                {
                    if(image != nil)
                    {
                        sheet?.add(image);
                    }
                    
                    if(url != nil)
                    {
                        sheet?.add(URL(string: url));
                    }
                }
                
                AppDelegate.getInstance().gameController.present(sheet!, animated: true, completion: {
                    AlertController.getInstance().hideAlert(nil);
                });
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
            print("share error");
            let source:String = (type == SLServiceTypeTwitter) ? "Twitter" : "Facebook";
            AlertController.getInstance().showAlert(source, message: "Please login to a \(source) account to share.", action: "OK", completion: nil);
        }
    }
    
    func screenShot(_ view:UIView)
    {
        self._currentScreenShot = view.takeSnapshot();
    }
}
