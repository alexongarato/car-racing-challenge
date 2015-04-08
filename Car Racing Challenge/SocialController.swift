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

class SocialController
{
    static var twitterType:String = SLServiceTypeTwitter;
    static var facebookType:String = SLServiceTypeFacebook;
    
    class func share(type:String, text:String, url:String! = nil, image:UIImage! = nil)
    {
        if(SLComposeViewController.isAvailableForServiceType(type))
        {
            var sheet:SLComposeViewController = SLComposeViewController(forServiceType: type);
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
            var source:String = (type == SLServiceTypeTwitter) ? "Twitter" : "Facebook";
            Utils.showAlert(title: "Accounts", message: "Please login to a \(source) account to share.", action: nil, cancel: "OK", completion: nil);
        }
    }
}