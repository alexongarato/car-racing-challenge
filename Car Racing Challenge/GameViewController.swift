//
//  GameViewController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate
{
    var scene                   : GameScene!;
    var sceneView               : SKView!;
    var menuView                : MenuView!;
    var statusView              : GameStatusView!;
    var snapshotView            : UIImageView!;
    var bestScoreEver           : NSInteger = 0;
    var showResumeOnStartUp     : Bool = false;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameController = self;
        
        var purchased:Bool = PurchaseController.getInstance().hasPurchased();
        
        sceneView = SKView();
        sceneView.frame = self.view.frame;
        
        sceneView.ignoresSiblingOrder = true;
        self.view.addSubview(sceneView);
        
//        sceneView.showsFPS = Configs.DEBUG_MODE;
//        sceneView.showsNodeCount = Configs.DEBUG_MODE;
        
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.updateGameStatusHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        sceneView.presentScene(scene);
        
        Trace.log("GameViewController -> \(scene.size.description as String)");
        
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        scene.lifeUpHandler = self.statusView.showSuccessAnimation;
        scene.lifeDownHandler = self.statusView.showErrorAnimation;
        
        let data:NSString = DataProvider.getString(SuiteNames.GameBestScoreSuite, key: SuiteNames.GameBestScoreKey) as NSString;
        if(data == "")
        {
            Trace.log("GameViewController -> oops. best score not restored.");
        }
         else
        {
            self.bestScoreEver = NSInteger(data.floatValue);
            Trace.log("GameViewController -> best score restored: \(self.bestScoreEver)");
            GameCenterController.reportScore(self.bestScoreEver);
        }
        
        self.scene.reset();
        self.scene.build();
        
        startGame();
    }
    
    override func didMoveToParentViewController(parent: UIViewController?)
    {
        (UIApplication.sharedApplication().delegate as! AppDelegate).startGameCenter();
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector!, showInstructions:Bool = false, showExitButton:Bool = true, showGameOver:Bool = false)
    {
        if(menuView != nil)
        {
            menuView.removeFromSuperview();
            menuView = nil;
        }
        
        scene.stop();
        statusView.hide();
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.Scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        
        if(showInstructions)
        {
            menuView.setInstructions(self.scene.lifeUpScore(), scoreToLevelUp: self.scene.levelUpScore());
        }
        else if(showGameOver)
        {
            menuView.setGameOver();
        }
        
        if(selector != nil)
        {
            menuView.setAction(action, target: self, selector: selector);
        }
        
        if(showExitButton)
        {
            menuView.setAction("exit", target: self, selector: Selector("exitHandler"));
        }
        
        menuView.present(nil);
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func exitHandler()
    {
        self.startGame();
    }
    
    func updateGameStatusHandler()
    {
        self.statusView.update(self.scene.currentLevel(),
            score: self.scene.currentScore(),
            nextScore: self.scene.levelUpScore(),
            lifes:scene.currentLifes(),
            scoreNextLife:self.scene.currentScoreToNextLife());
    }
    
    func startGame()
    {
        showMenu("car racing\nchallenge",
            desc: "How far can you go?", action: "PLAY", selector: Selector("startGameHandler"), showInstructions:true, showExitButton:false);
        AudioHelper.playSound(AudioHelper.EntranceSound);
        
        self.showBanner();
    }
    
    func startGameHandler()
    {
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            self.scene.reset();
            self.scene.build();
            self.scene.start();
        }
        
        self.menuView.dismiss(complete);
        
        AudioHelper.playSound(AudioHelper.StartGameSound);
    }
    
    func gameOverHandler()
    {
        scene.stop();
        
        if(scene.currentScore() > self.bestScoreEver)
        {
            self.bestScoreEver = scene.currentScore();
            DataProvider.saveData(SuiteNames.GameBestScoreSuite, key: SuiteNames.GameBestScoreKey, string: "\(self.bestScoreEver)");
            if(!GameCenterController.isReady())
            {
                GameCenterController.authenticate({ GameCenterController.reportScore(self.bestScoreEver); });
            }
            else
            {
                GameCenterController.reportScore(self.bestScoreEver);
            }
        }
        
        showMenu("\nGAME OVER", desc: "SCORE:\(scene.currentScore())\nBEST:\(self.bestScoreEver)", action: "RESTART", selector: Selector("startGameHandler"), showGameOver:true);
        AudioHelper.playSound(AudioHelper.GameOverSound);
        
        self.showBanner();
    }
    
    func levelUpHandler()
    {
        Trace.log("GameViewController -> LEVEL UP");
        
        var ttl:String = "\nRACE TRACK\nUPGRADE \(scene.currentLevel())\n";
        var desc:String!;
        var act:String = "GO!";
        var selector:Selector = Selector("resumeLevelUp");
        
        if(!Configs.SAMPLE_MODE)
        {
            if(scene.currentLevel() <= scene.maximunLevel())
            {
                desc = "\n\ncongratulations!";
            }
            else if(scene.currentLevel() == scene.maximunLevel() + 1)
            {
                desc = "\n\nThis is the highest\nracing track level!";
            }
            if(desc != nil)
            {
                scene.stop();
                showMenu(ttl, desc: desc, action: act, selector: selector, showExitButton:false);
                scene.setTotalColumns(scene.currentColumns() - 1);
                self.showBanner();
            }
        }
        else
        {
            scene.stop();
            selector = nil;
            ttl = "FREE VERSION";
            desc = "This free version is limited\nto one level only.";
            showMenu(ttl, desc: desc, action: "", selector: nil, showExitButton:true);
            self.showBanner();
        }
        
        AudioHelper.playSound(AudioHelper.LevelUpSound);
    }
    
    func resumeLevelUp()
    {
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            self.scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    //################### PRAGMA
    func applicationWillResignActive()
    {
        Trace.log("GameViewController -> app will resign active");
        
        if(!self.scene.isGamePaused())
        {
            self.scene.stop();
            self.showResumeOnStartUp = true;
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
    }
    
    func applicationDidBecomeActive()
    {
        Trace.log("GameViewController -> app did become active");
        
        if(self.showResumeOnStartUp)
        {
            self.showResumeOnStartUp = false;
            showMenu("RESUME\nCAR RACING\nCHALLENGE\n\n", desc: " \n \n \nARE YOU READY?", action: "YES!", selector: Selector("resumeLevelUp"));
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        Trace.log("GameViewController -> GameCenter did finish");
        
        self.dismissViewControllerAnimated(true, completion:
            {
                self.applicationDidBecomeActive();
        });
    }
    
    func showBanner()
    {
        if(Configs.SAMPLE_MODE)
        {
            Trace.log("GameViewController -> show banner");
        }
    }

    override func shouldAutorotate() -> Bool
    {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
}
