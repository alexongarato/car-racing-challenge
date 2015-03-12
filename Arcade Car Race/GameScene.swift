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
    var buttonLeft              : SKSpriteNode!;
    var buttonRight             : SKSpriteNode!;
    var mainCharacter           : SKSpriteNode!;
    var enemiesArray            : Array<CustomEnemy>!;
    var slideVelocity           : CGFloat = 0;
    var currentVelocity         : CGFloat = 2;
    var currentLevel            : CGFloat = 1;
    var controlButtonsSize      : CGFloat = 0;
    var enemySize               : CGFloat = 0;
    var levelTriggerCounter     : Int = 1;
    var enemyTriggerCounter     : Int = 0;
    var distBetweenEnemies      : Int = 0;
    var mainCharacterRadius     : CGFloat = 0;
    var totalLifes              : Int = 10;
    var isGameOver              : Bool = false;
    
    /**/
    let distBetweenLevels       : Int = 700;
    let totalColumns            : Int = 4;
    let velocityIncrement       : CGFloat = 1;
    
    
    override func didMoveToView(view: SKView)
    {
        enemiesArray = Array<CustomEnemy>();
        enemySize = self.size.width / CGFloat(totalColumns);
        controlButtonsSize = self.size.width * 0.5;
        
        //set main controll buttons
        buttonLeft = self.childNodeWithName("bt_left") as SKSpriteNode;
        buttonRight = self.childNodeWithName("bt_right") as SKSpriteNode;
        
        buttonLeft.size.width = controlButtonsSize;
        buttonLeft.size.height = controlButtonsSize.half;
        
        buttonRight.size.width = controlButtonsSize;
        buttonRight.size.height = controlButtonsSize.half;
        
        buttonLeft.position.x = buttonLeft.size.width.half;
        buttonLeft.position.y = buttonLeft.size.height.half;
        
        buttonRight.position.x = self.size.width - buttonRight.size.width.half;
        buttonRight.position.y = buttonRight.size.height.half;
        
        //set main character
        mainCharacter = SKSpriteNode();
        mainCharacter.color = UIColor.greenColor();
        mainCharacter.size.width = enemySize.half;
        mainCharacter.size.height = enemySize;
        mainCharacter.position.x = self.size.width.half;
        mainCharacter.position.y = buttonRight.size.height + mainCharacter.size.height;
        
        //
        mainCharacterRadius = mainCharacter.size.height;
        
        self.addChild(mainCharacter);
        
        //set variables
        slideVelocity = (self.size.width - mainCharacter.size.width) / CGFloat(totalColumns);
        
        addNewEnemy();
        
        printStatus();
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
                if(mainCharacter.position.x > mainCharacter.size.width.half)
                {
                    mainCharacter.position.x -= slideVelocity;
                    if(mainCharacter.position.x < mainCharacter.size.width.half)
                    {
                        mainCharacter.position.x = mainCharacter.size.width.half;
                    }
                }
            }
            
            if(node.name == "bt_right")
            {
                if(mainCharacter.position.x < self.size.width - mainCharacter.size.width.half)
                {
                    mainCharacter.position.x += slideVelocity;
                    if(mainCharacter.position.x > self.size.width - mainCharacter.size.width.half)
                    {
                        mainCharacter.position.x = self.size.width - mainCharacter.size.width.half;
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
    
    
    func showGameOverMessage()
    {
        let myLabel = SKLabelNode(fontNamed:"Chalkduster");
        myLabel.text = "GAME OVER";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }

    override func update(currentTime: CFTimeInterval)
    {
        if(isGameOver)
        {
            return;
        }
        
        levelTriggerCounter++;
        enemyTriggerCounter++;
        
        distBetweenEnemies = Int(enemySize * 3) / Int(currentLevel);
        
        if(enemyTriggerCounter > distBetweenEnemies)
        {
            enemyTriggerCounter = 0;
            addNewEnemy();
        }
        
        for enemyBlock in enemiesArray
        {
            if(enemyBlock.position.x == mainCharacter.position.x)
            {
                if(enemyBlock.position.y <= (mainCharacter.position.y + mainCharacterRadius) && enemyBlock.position.y >= (mainCharacter.position.y - mainCharacterRadius))
                {
                    if(!enemyBlock.isTouched)
                    {
                        enemyBlock.isTouched = true;
                        enemyBlock.color = UIColor.blueColor();
                        totalLifes--;
                        printStatus();
                        if(totalLifes == 0)
                        {
                            isGameOver = true;
                            showGameOverMessage();
                        }
                    }
                }
            }
            
            enemyBlock.position.y -= currentVelocity;
            
            if(enemyBlock.position.y + enemyBlock.size.height.half < 0)//end on enemy life
            {
                enemyBlock.position.y = self.size.height + enemyBlock.size.height.half;
                enemyBlock.removeFromParent();
                enemiesArray.removeAtIndex(0);
            }
            
            if(levelTriggerCounter > distBetweenLevels)
            {
                currentLevel++;
                currentVelocity += velocityIncrement;
                levelTriggerCounter = 0;
//                addNewEnemy()//add bonus enemy
                printStatus();
            }
        }
    }
    
    func addNewEnemy()
    {
        var newEnemy:CustomEnemy = CustomEnemy();
        newEnemy.size.width = enemySize.half;
        newEnemy.size.height = enemySize;
        newEnemy.color = UIColor.redColor();
        newEnemy.position.x = newEnemy.size.width.half + (slideVelocity * CGFloat(random(totalColumns)));
        newEnemy.position.y = self.size.height + newEnemy.size.height.half;
        enemiesArray.append(newEnemy);
        self.addChild(newEnemy);
        newEnemy.zPosition = -1;
    }
    
    func random(i:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(1+i)));
    }
    
    func printStatus()
    {
        NSLog("level:\(currentLevel) - life:\(totalLifes) - velocity:\(currentVelocity)");
    }
}

class CustomEnemy:SKSpriteNode
{
    var isTouched:Bool = false;
}
