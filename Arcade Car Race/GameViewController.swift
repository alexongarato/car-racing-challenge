//
//  GameViewController.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene:GameScene!;
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
//        scene.size.width -= 20;
        scene.size.height -= 40;
//        scene.scaleMode = SKSceneScaleMode.AspectFit;
        scene.updateStatusHandler = self.gameStatusUpdateHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        scene.finalSceneHandler = self.finalSceneHandler;
        let skView:SKView = self.view as! SKView;
        skView.showsFPS = Configs.DEBUG_MODE;
        skView.showsNodeCount = Configs.DEBUG_MODE;
        skView.ignoresSiblingOrder = true;
        skView.presentScene(scene);
        
        scene.build();
        scene.start();
        
        Trace.log(scene.size.description as String);
    }
    
    func gameStatusUpdateHandler()
    {
        Trace.log("SCORE:\(scene.currentScore())");
    }
    
    func gameOverHandler()
    {
        Trace.log("GAME OVER");
        scene.stop();
    }
    
    func levelUpHandler()
    {
        Trace.log("LEVEL UP");
        scene.setTotalColumns(scene.currentColumns() - 1);
        scene.start();
    }
    
    func finalSceneHandler()
    {
        Trace.log("VICTORY");
        scene.stop();
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
