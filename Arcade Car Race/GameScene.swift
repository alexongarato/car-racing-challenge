//
//  GameScene.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    var buttonLeft          : SKSpriteNode!;
    var buttonRight         : SKSpriteNode!;
    var mainCharacter       : SKSpriteNode!;
    var enemiesArray        : Array<SKSpriteNode>!;
    var slideVelocity       : CGFloat = 0;
    var enemyVelocity       : CGFloat = 1;
    var maxEnemies          : CGFloat = 5;
    
    
    override func didMoveToView(view: SKView)
    {
        //
        enemiesArray = Array<SKSpriteNode>();
        
        //set main controll buttons
        buttonLeft = self.childNodeWithName("bt_left") as SKSpriteNode;
        buttonRight = self.childNodeWithName("bt_right") as SKSpriteNode;
        
        var btSize:CGFloat = self.size.width * 0.5;
        
        buttonLeft.size.width = btSize;
        buttonLeft.size.height = btSize;
        
        buttonRight.size.width = btSize;
        buttonRight.size.height = btSize;
        
        buttonLeft.position.x = buttonLeft.size.width * 0.5;
        buttonLeft.position.y = buttonLeft.size.width * 0.5;
        
        buttonRight.position.x = self.size.width - buttonRight.size.width * 0.5;
        buttonRight.position.y = buttonRight.size.height * 0.5;
        
        //set main character
        mainCharacter = SKSpriteNode(imageNamed:"Spaceship");
        mainCharacter.setScale(0.27);
        mainCharacter.position.x = self.size.width * 0.5;
        mainCharacter.position.y = btSize + (mainCharacter.size.width * 0.5);
        self.addChild(mainCharacter);
        
        //set enemies
        
        enemyBlock = self.childNodeWithName("enemy") as SKSpriteNode;
        enemyBlock.size = mainCharacter.size;
        enemyBlock.setScale(0.5);
        enemyBlock.position.x = btSize;
        
        //set variables
        slideVelocity = (self.size.width - mainCharacter.size.width) / 2;
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location);
            if(node.name == "bt_left")
            {
                NSLog("touch left button");
                if(mainCharacter.position.x > mainCharacter.size.width * 0.5)
                {
                    mainCharacter.position.x -= slideVelocity;
                    if(mainCharacter.position.x < mainCharacter.size.width * 0.5)
                    {
                        mainCharacter.position.x = mainCharacter.size.width * 0.5;
                    }
                }
            }
            
            if(node.name == "bt_right")
            {
                NSLog("touch right button");
                
                if(mainCharacter.position.x < (self.size.width - mainCharacter.size.width * 0.5))
                {
                    mainCharacter.position.x += slideVelocity;
                    if(mainCharacter.position.x > (self.size.width - mainCharacter.size.width * 0.5))
                    {
                        mainCharacter.position.x = (self.size.width - mainCharacter.size.width * 0.5);
                    }
                }
            }
            
            /*
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)*/
            
        }
    }
    
    /*
    func showPrepareMessage()
    {
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Ready";
        myLabel.fontSize = 50;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    */
   
    override func update(currentTime: CFTimeInterval)
    {
        enemyBlock.position.y -= 1;
        if(enemyBlock.position.y + (enemyBlock.size.height * 0.5) < 0)
        {
            enemyBlock.position.y = self.size.height + (enemyBlock.size.height * 0.5);
            enemyVelocity+=2;
        }
    }
}
