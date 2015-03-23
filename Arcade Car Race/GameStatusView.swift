//
//  GameStatusView.swift
//  Infinity Car Race
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
class GameStatusView:AbstractView
{
    private var scoreField:UILabel!;
    private var levelField:UILabel!;
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.alpha = 0;
        self.height = 22;
        self.y = -self.height;
        self.backgroundColor = UIColor.whiteColor().alpha(0.3);
        
        self.levelField = UILabel();
        self.addSubview(self.levelField);
        self.levelField.y = 5
        self.levelField.x = 30;
        self.levelField.font = Fonts.Digital7Italic(FontSize.Small);
        self.levelField.textColor = UIColor.blackColor();
        
        self.scoreField = UILabel();
        self.addSubview(self.scoreField);
        self.scoreField.y = 5;
        self.scoreField.x = self.center.x;
        self.scoreField.font = Fonts.Digital7Italic(FontSize.Small);
        self.scoreField.textColor = UIColor.blackColor();
    }
    
    func show()
    {
        UIView.animateWithDuration(AnimationTime.VerySlow, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.y = 0;
            self.alpha = 1;
            }, completion: nil);
    }
    
    func hide()
    {
        UIView.animateWithDuration(AnimationTime.Default, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.y = -self.height;
            self.alpha = 0;
            }, completion: nil);
    }
    
    func update(level:Int, score:Int, nextScore:Int)
    {
        self.levelField.text = "LEVEL: \(level)";
        self.levelField.sizeToFit();
        
        self.scoreField.text = "SCORE: \(score)/\(nextScore * level)";
        self.scoreField.sizeToFit();
    }
}