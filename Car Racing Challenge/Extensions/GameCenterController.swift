//
//  GameCenterController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
import GameKit

private var currentPlayerID                     : NSString!;
private var isGameCenterAuthenticationComplete  : Bool = false;
private var localPlayer                         : GKLocalPlayer!;

class GameCenterController
{
    // Check for the availability of Game Center API.
    class func isGameCenterAPIAvailable() -> Bool
    {
    // Check for presence of GKLocalPlayer API.
        var gcClass:AnyClass! = NSClassFromString("GKLocalPlayer");
        var systemVersion:NSString = UIDevice.currentDevice().systemVersion;
        return (gcClass != nil && systemVersion.floatValue >= 4.1);
    }
    
    class func setReadyStatus(value:Bool)
    {
        isGameCenterAuthenticationComplete = value;
    }
    
    class func isReady() -> Bool
    {
        return isGameCenterAuthenticationComplete;
    }
    
    class func start()
    {
        localPlayer = GKLocalPlayer.localPlayer();
        setReadyStatus(false);
        
        Trace.log("GameCenterController -> start");
        
        /*
        The authenticateWithCompletionHandler method is like all completion handler methods and runs a block
        of code after completing its task. The difference with this method is that it does not release the
        completion handler after calling it. Whenever your application returns to the foreground after
        running in the background, Game Kit re-authenticates the user and calls the retained completion
        handler. This means the authenticateWithCompletionHandler: method only needs to be called once each
        time your application is launched. This is the reason the sample authenticates in the application
        delegate's application:didFinishLaunchingWithOptions: method instead of in the view controller's
        viewDidLoad method.
        
        Remember this call returns immediately, before the user is authenticated. This is because it uses
        Grand Central Dispatch to call the block asynchronously once authentication completes.
        */
        
        func handler(view:UIViewController!, error:NSError!)
        {
            Trace.log("GameCenterController -> auth complete.");
            
            // If there is an error, do not assume local player is not authenticated.
            if (localPlayer.authenticated)
            {
                // Enable Game Center Functionality
                setReadyStatus(true);
                currentPlayerID = localPlayer.playerID;
                
                Trace.log("GameCenterController -> user authenticated (\(currentPlayerID))");
            }
            else
            {
                Trace.log("GameCenterController ->auth error");
            }
        }
        
        Trace.log("GameCenterController -> authenticating...")
        localPlayer.authenticateHandler = handler;
    }
}