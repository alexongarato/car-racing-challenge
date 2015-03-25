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
private var leaderBoardID                       : String = "car_racing_challenge";

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
    
    private class func leaderboardHandler(error:NSError!)
    {
        if(error != nil)
        {
            Trace.error("GameCenterController -> set default leaderboard ID FAILED!")
        }
        else
        {
            Trace.warning("GameCenterController -> set default leaderboard ID SUCCEED!")
        }
    }
    
    class func authenticate(callback:(()->Void!)!)
    {
        if(!GameCenterController.isGameCenterAPIAvailable())
        {
            Trace.error("GameCenterController -> GKLocalPlayer NOT READY!")
            return;
        }
        
        Trace.log("GameCenterController -> start");
        localPlayer = GKLocalPlayer.localPlayer();
        setReadyStatus(false);
        localPlayer.setDefaultLeaderboardIdentifier(leaderBoardID, completionHandler: leaderboardHandler);
        
        
        Trace.log("GameCenterController -> authenticating...")
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
            if (view != nil)
            {
                if(UICustomDevice.isIOS8OrHigher())
                {
                    //showAuthenticationDialogWhenReasonable: is an example method name.
                    //Create your own method that displays an authentication view when appropriate for your app.
                    (UIApplication.sharedApplication().delegate as! AppDelegate).gameController.showViewController(view, sender: nil);
                }
                else
                {
                    
                }
            }
            else if (localPlayer.authenticated)
            {
                // Enable Game Center Functionality
                self.setReadyStatus(true);
                currentPlayerID = localPlayer.playerID;
                
                if(callback != nil)
                {
                    callback();
                }
                
                Trace.log("GameCenterController -> user authenticated (\(currentPlayerID))");
            }
            else
            {
                Trace.error("GameCenterController -> auth error");
                Utils.showAlert(title: "Game Center Settings", message: "Offline mode alert.\n\nTo make your scores available\nto your friends, please check\nGame Center permissions\nunder Settings.");
            }
        }
        
        localPlayer.authenticateHandler = handler;
    }
    
    class func loadLeaderboardInfo()
    {
        func completion(leaderboards:[AnyObject]!, error:NSError!)
        {
            
        }
        
        GKLeaderboard.loadLeaderboardsWithCompletionHandler(completion);
    }
    
    class func reportScore(score:Int)
    {
        var scoreReporter:GKScore = GKScore(leaderboardIdentifier: leaderBoardID);
        scoreReporter.value = Int64(score);
        scoreReporter.context = 0;
        
        func completion(error:NSError!)
        {
            Trace.log("score reported:\(score)");
        }
        
        GKScore.reportScores([scoreReporter], withCompletionHandler: completion);
    }
}