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
        let gcClass:AnyClass! = NSClassFromString("GKLocalPlayer");
        let systemVersion:NSString = UIDevice.currentDevice().systemVersion;
        return (gcClass != nil && systemVersion.floatValue >= 4.1);
    }
    
    class func start()
    {
        GameCenterController.authenticate(GameCenterController.fetchUserScores);
    }
    
    class func setReadyStatus(value:Bool)
    {
        isGameCenterAuthenticationComplete = value;
    }
    
    class func isReady() -> Bool
    {
        return isGameCenterAuthenticationComplete;
    }
    
    private class func leaderboardHandler(error:NSError?)
    {
        if(error != nil)
        {
            Trace("GameCenterController -> set default leaderboard ID FAILED!")
        }
        else
        {
            Trace("GameCenterController -> set default leaderboard ID SUCCEED!")
        }
    }
    
    class func authenticate(callback:(()->Void)!)
    {
        if(!GameCenterController.isGameCenterAPIAvailable())
        {
            Trace("GameCenterController -> GKLocalPlayer NOT READY!")
            return;
        }
        
        Trace("GameCenterController -> start");
        localPlayer = GKLocalPlayer.localPlayer();
        setReadyStatus(false);
        localPlayer.setDefaultLeaderboardIdentifier(leaderBoardID, completionHandler: leaderboardHandler);
        
        
        Trace("GameCenterController -> authenticating...");
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
        
        func handler(view:UIViewController?, error:NSError?) -> Void
        {
            Trace("GameCenterController -> auth complete.");
            
            
            // If there is an error, do not assume local player is not authenticated.
            if (view != nil)
            {
                if(UICustomDevice.isIOS8OrHigher())
                {
                    //showAuthenticationDialogWhenReasonable: is an example method name.
                    //Create your own method that displays an authentication view when appropriate for your app.
                    AppDelegate.getInstance().gameController.applicationWillResignActive();
                    AppDelegate.getInstance().gameController.presentViewController(view!, animated: true, completion: {
                        AppDelegate.getInstance().gameController.applicationDidBecomeActive();
                    })
                }
            }
            else if (localPlayer.authenticated)
            {
                // Enable Game Center Functionality
                self.setReadyStatus(true);
                currentPlayerID = localPlayer.playerID;
                Trace("GameCenterController -> user authenticated (\(currentPlayerID))");
                
                if(callback != nil)
                {
                    callback();
                }
            }
            else
            {
                Trace("GameCenterController -> auth error");
//                AppDelegate.getInstance().gameController.applicationWillResignActive();
//                AlertController.getInstance().showAlert(title: "Game Center Unavailable", message: "Player is not signed in", completion:{
//                    AppDelegate.getInstance().gameController.applicationDidBecomeActive();
//                });
            }
        }
        
        localPlayer.authenticateHandler = handler;
    }
    
    class func fetchUserScores()
    {
        var leaderboardRequest:GKLeaderboard;
        leaderboardRequest =  GKLeaderboard(players: [localPlayer]);
        leaderboardRequest.identifier = leaderBoardID;
        leaderboardRequest.playerScope = GKLeaderboardPlayerScope.Global;
        leaderboardRequest.timeScope = GKLeaderboardTimeScope.AllTime;
        leaderboardRequest.range = NSMakeRange(1,1);
        leaderboardRequest.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if (scores != nil)
            {
                let newScore:NSInteger = NSInteger(leaderboardRequest.localPlayerScore!.value);
                let bestScore:NSInteger = AppDelegate.getInstance().gameController.getBestScore();
                if(newScore > bestScore)
                {
                    Trace("GameCenterController -> gest score from leaderboard: \(newScore)");
                    AppDelegate.getInstance().gameController.setBestScore(newScore);
                }
                else
                {
                    Trace("GameCenterController -> gest score from leaderboard: equal or lower than local (\(newScore)/\(bestScore))");
                }
                
            }
            else
            {
                Trace("GameCenterController -> gest score from leaderboard: error");
                error;
            }
        }
    }
    
    class func loadLeaderboard()
    {
        func completion(leaderboards:[GKLeaderboard]?, error:NSError?) -> Void
        {
            //AlertController.getInstance().hideAlert({
                let gameCenterController:GKGameCenterViewController! = GKGameCenterViewController();
                
                if (gameCenterController != nil)
                {
                    gameCenterController.gameCenterDelegate = AppDelegate.getInstance().gameController;
                    gameCenterController.viewState = GKGameCenterViewControllerState.Achievements;
//                    gameCenterController.leaderboardIdentifier = leaderBoardID;
                    AppDelegate.getInstance().gameController.applicationWillResignActive();
                    AppDelegate.getInstance().gameController.presentViewController(gameCenterController, animated: true, completion: {
                        AlertController.getInstance().hideAlert(nil);
                    });
                }
                else
                {
                    AlertController.getInstance().hideAlert(nil);
                }
            //});
        }
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
        
        //AlertController.getInstance().showAlert(message: "Loading...", action: nil, completion:{
            GKLeaderboard.loadLeaderboardsWithCompletionHandler(completion);
        //});
    }
    
    class func reportScore(score:Int)
    {
        var scoreReporter:GKScore = GKScore(leaderboardIdentifier: leaderBoardID);
        scoreReporter.value = Int64(score);
        scoreReporter.context = 0;
        scoreReporter.shouldSetDefaultLeaderboard = !UICustomDevice.isIOS8OrHigher();
        
        func completion(error:NSError?) -> Void
        {
            Trace("GameCenterController -> score reported:\(score)");
        }
        
        GKScore.reportScores([scoreReporter], withCompletionHandler: completion);
    }
}