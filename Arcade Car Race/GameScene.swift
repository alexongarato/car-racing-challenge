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
    //-- pointers --
    private var buttonLeft              : SKSpriteNode!;
    private var buttonRight             : SKSpriteNode!;
    private var mainCharacter           : CustomSpriteNode!;
    private var enemiesArray            : Array<CustomSpriteNode>!;
    private var buttonSize              : CGSize = CGSize();
    private var charactersSize          : CGSize = CGSize();
    private var pixelSize               : CGFloat = 0;
    private var gameFrame               : CGRect!;
    var updateStatusHandler             : (() -> Void!)!;
    var gameOverHandler                 : (() -> Void!)!;
    
    //-- configs --
    private var totalColumns            : Int = 6;
    private var levelCounter            : Int = 1;
    private var lifesCounter            : Int = 1;
    private var isGameOver              : Bool = false;
    private var enemiesAvoidedCounter   : Int = 0;
    private var levelUpCounter          : Int = 0;
    private let totalAvoidedToLevelUp   : Int = 1;
    private let IDBtLeft                : String = "bt_left";
    private let IDBtRight               : String = "bt_right";
    private var ready                   : Bool = false;
    private var builded                 : Bool = false;
    
    /**
    quanto menor, maior a velocidade do jogo
    */
    private let intervalBetweenLevels   : CFTimeInterval = 0.01;
    private var loopsTimeCounter        : CFTimeInterval = -1;
    private var intervalBetweenLoops    : CFTimeInterval = 0.5;
    
    private let newEnemyTotal           : Int = 12;
    private var newEnemyCounter         : Int = 12;
    
    func setTotalColumns(value:Int)
    {
        if(value >= 3 && value <= 6)
        {
            self.totalColumns = value;
        }
        else
        {
            Trace.error("INVALID COLUMN NUMBER (\(value))");
        }
        
    }
    
    func currentScore() -> Int
    {
        return self.enemiesAvoidedCounter;
    }
    
    func currentLifes() -> Int
    {
        return self.lifesCounter;
    }
    
    func build()
    {
        self.removeAllChildren();
        
        /**
        inicializar variaveis
        */
        self.gameFrame                  = CGRect(origin: self.position, size: CGSize(width: self.size.width * 0.8, height: self.size.height * 0.9));
        self.enemiesArray               = Array<CustomSpriteNode>();
        self.pixelSize                  = CGFloat(self.gameFrame.width.intValue / (self.totalColumns * 3));
        self.charactersSize.width       = self.pixelSize * 3;
        self.charactersSize.height      = self.pixelSize * 4;
        self.buttonSize.width           = self.gameFrame.width.half.roundValue;
        self.buttonSize.height          = self.buttonSize.width.half.roundValue;
        
        Trace.log("pixelSize:\(self.pixelSize)");
        
        /**
        criar malha de pixels de acordo com a quantidade de pistas.
        */
        var pixelFrame:CGRect = CGRect(x: 0, y: 0, width: self.pixelSize, height: self.pixelSize);
        var pixelCGImage:CGImageRef = UIImage(named:"PixelOff")!.CGImage;
        
        UIGraphicsBeginImageContext(self.gameFrame.size);
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, self.gameFrame, UIImage(named:"Background")!.CGImage);
        CGContextDrawTiledImage(context, pixelFrame, pixelCGImage);
        var tiledPixels:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        var pixelTexture:SKTexture = SKTexture(CGImage: tiledPixels.CGImage);
        
        var pixelsNode:SKSpriteNode = SKSpriteNode(texture: pixelTexture);
        self.addChild(pixelsNode);
        pixelsNode.zPosition = 1;
        pixelsNode.anchorPoint.x = 0;
        pixelsNode.anchorPoint.y = 1;
        pixelsNode.x = 0;
        pixelsNode.y = self.gameFrame.height;
        
        /**
        cria os personagens do jogo
        */
        self.mainCharacter = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize));
        self.mainCharacter.size = self.charactersSize;
        self.mainCharacter.x = self.mainCharacter.width.half;
        self.mainCharacter.y = (self.pixelSize * 7);
        self.mainCharacter.x = (self.mainCharacter.width * CGFloat(self.totalColumns / 2).roundValue) + self.mainCharacter.width.half;
        self.addChild(self.mainCharacter);
        
        /**
        cria os controles do jogo
        */
        self.buttonLeft = SKSpriteNode();
        self.buttonLeft.size = self.buttonSize;
        self.buttonLeft.color = UIColor.yellowColor();
        self.buttonLeft.alpha = 0.5;
        self.buttonLeft.x = self.buttonLeft.width.half;
        self.buttonLeft.y = self.buttonLeft.height.half;
        self.buttonLeft.name = self.IDBtLeft;
        self.addChild(self.buttonLeft);
        
        self.buttonRight = SKSpriteNode();
        self.buttonRight.size = self.buttonSize;
        self.buttonRight.color = UIColor.redColor();
        self.buttonRight.alpha = 0.5;
        self.buttonRight.x = self.gameFrame.width - self.buttonRight.width.half;
        self.buttonRight.y = self.buttonRight.height.half;
        self.buttonRight.name = self.IDBtRight;
        self.addChild(self.buttonRight);
        
        /**
        configurar posicao z da interface
        */
        self.mainCharacter.zPosition = 20;
        self.buttonLeft.zPosition = 21;
        self.buttonRight.zPosition = 22;
        
        
        self.builded = true;
    }
    
    func start()
    {
        if(!self.builded)
        {
            Trace.error("GAME IS NOT READY!");
            return;
        }
        
        self.ready = true;
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if(isGameOver || !self.ready)
        {
            return;
        }
        
        /**
        processa cada inimigo individualmente
        */
        if(currentTime >= loopsTimeCounter)
        {
            /**
            novo heart beat
            */
            
            //-----------
            loopsTimeCounter = currentTime + intervalBetweenLoops;
            //-----------
            
            self.newEnemyCounter++;
            if(self.newEnemyCounter >= self.newEnemyTotal)
            {
                self.newEnemyCounter = 0;
                addNewEnemy();
            }
            
            for enemyBlock in enemiesArray
            {
                /**
                move o inimigo para baixo
                */
                enemyBlock.y -= pixelSize;
                
                /**
                quando o inimigo sai da tela. end of life.
                */
                if(enemyBlock.y + enemyBlock.height.half < 0)
                {
                    if(!enemyBlock.isTouched)
                    {
                        enemiesAvoidedCounter++;
                        self.levelUpCounter++;
                        if(self.levelUpCounter > self.totalAvoidedToLevelUp)
                        {
                            self.levelUpCounter = 0;
                            self.levelCounter++;
                        }
                    }
                    
                    self.removeChildrenInArray([enemyBlock]);
                    enemiesArray.removeAtIndex(0);
                    self.updateStatusHandler();
                }
            }
        }
        
        for enemyBlock in enemiesArray
        {
            if(enemyBlock.intersectsNode(mainCharacter) && enemyBlock.y > self.mainCharacter.y - self.mainCharacter.height.half)
            {
                if(!enemyBlock.isTouched)
                {
                    enemyBlock.isTouched = true;
                    
                    /**
                    customizar inimigo quando atingido
                    */
                    enemyBlock.color = UIColor.blueColor();
                    
                    
                    /**
                    atualizacao das variaveis do jogo
                    */
                    lifesCounter--;
                    self.updateStatusHandler();
                    if(lifesCounter == 0)
                    {
                        isGameOver = true;
                        self.gameOverHandler();
                        return;
                    }
                }
            }
        }
        
        if(self.intervalBetweenLoops > 0.03)
        {
//            self.intervalBetweenLoops -= 0.003;
        }
    }
    
    override func touchesBegan(touches: (NSSet!), withEvent event: UIEvent)
    {
        if(isGameOver || !self.ready)
        {
            return;
        }
        
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location);
            if(node.name == self.IDBtLeft)
            {
                if(mainCharacter.x > mainCharacter.width)
                {
                    mainCharacter.x -= mainCharacter.width;
                }
            }
            
            if(node.name == self.IDBtRight)
            {
                if(mainCharacter.x < self.size.width - mainCharacter.width)
                {
                    mainCharacter.x += mainCharacter.width;
                }
            }
        }
    }
    
    private func addNewEnemy()
    {
        var newEnemy:CustomSpriteNode = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize), size: self.charactersSize);
        newEnemy.size = self.charactersSize;
        newEnemy.anchorPoint.x = 0;
        newEnemy.anchorPoint.y = 1;
        newEnemy.x = self.charactersSize.width.half + (self.charactersSize.width * Utils.random(self.totalColumns - 1).floatValue);
        newEnemy.y = self.gameFrame.height;
        newEnemy.zPosition = 10;
        self.addChild(newEnemy);
        self.enemiesArray.append(newEnemy);
    }
}


