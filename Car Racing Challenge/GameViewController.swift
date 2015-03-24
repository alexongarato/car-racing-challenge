//
//  GameViewController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene           : GameScene!;
    var sceneView       : SKView!;
    var menuView        : MenuView!;
    var statusView      : GameStatusView!;
    var snapshotView    : UIImageView!;
    var bestScoreEver   : NSInteger = 0;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        //
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.gameStatusUpdateHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        
        Trace.log(scene.size.description as String);
        
        //
        sceneView = SKView();
        sceneView.frame = self.view.frame;
        sceneView.showsFPS = Configs.DEBUG_MODE;
        sceneView.showsNodeCount = Configs.DEBUG_MODE;
        sceneView.ignoresSiblingOrder = true;
        sceneView.presentScene(scene);
        self.view.addSubview(sceneView);
        
        //
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        let data:NSString = DataProvider.getString(SuiteNames.GameBestScoreSuite, key: SuiteNames.GameBestScoreKey) as NSString;
        if(data == "")
        {
            Trace.log("oops. best score not restored.");
        }
         else
        {
            self.bestScoreEver = NSInteger(data.floatValue);
            Trace.log("best score restored: \(self.bestScoreEver)");
        }
        
        //
        scene.reset();
        scene.build();
        
        showMenu("car racing\nchallenge", desc: "limitless score!\nHow far can you go?", action: "PRESS TO START", selector: Selector("startGame"));
        
        AudioHelper.playSound(AudioHelper.EntranceSound);
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector)
    {
        scene.paused = true;
        statusView.hide();
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.Scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        menuView.setAction(action, target: self, selector: selector);
        menuView.present(nil);
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func gameStatusUpdateHandler()
    {
        self.statusView.update(self.scene.currentLevel(),
            score: self.scene.currentScore(),
            nextScore: self.scene.currentScoreToLevelUp(),
            lifes:scene.currentLifes(),
            scoreNextLife:self.scene.currentScoreToNextLife());
    }
    
    func startGame()
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
            
            scene.start();
        }
        
        self.menuView.dismiss(complete);
        
        AudioHelper.playSound(AudioHelper.SelectSound);
    }
    
    func restartGame()
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
            
            scene.reset();
            scene.build();
            scene.start();
        }
        
        self.menuView.dismiss(complete);
        
        AudioHelper.playSound(AudioHelper.StartGameSound);
    }
    
    func gameOverHandler()
    {
        if(scene.currentScore() > self.bestScoreEver)
        {
            self.bestScoreEver = scene.currentScore();
            DataProvider.saveData(SuiteNames.GameBestScoreSuite, key: SuiteNames.GameBestScoreKey, string: "\(self.bestScoreEver)");
        }
        
        scene.stop();
        showMenu("\nGAME OVER", desc: "current SCORE: \(scene.currentScore())\n\nBEST SCORE EVER:\(self.bestScoreEver)", action: "TRY AGAIN", selector: Selector("restartGame"));
        
        AudioHelper.playSound(AudioHelper.GameOverSound);
    }
    
    func levelUpHandler()
    {
        Trace.log("LEVEL UP");
        
        var desc:String!;
        if(scene.currentLevel() <= scene.maximunLevel())
        {
            desc = "Less cars but more speed.\ndrive carefully!";
        }
        else if(scene.currentLevel() == scene.maximunLevel() + 1)
        {
            desc = "you've reached the outside road. \nIt will fit \(self.scene.currentColumns()) cars\nand your car is faster\nthen ever with infinite score and level.\n good luck!";
        }
        
        if(desc != nil)
        {
            scene.stop();
            showMenu("\nLEVEL \(scene.currentLevel())", desc: desc, action: "GO!", selector: Selector("resumeLevelUp"));
            scene.setTotalColumns(scene.currentColumns() - 1);
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
            
            scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    //
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
