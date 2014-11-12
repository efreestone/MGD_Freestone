// Elijah Freestone
// MGD 1411
// Week 3
// November 8th, 2014

//
//  GameOverScene.m
//  Project3
//
//  Created by Elijah Freestone on 11/8/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene {
    SKAction *waitDuration;
    SKAction *revealGameScene;
    SKAction *changeLabelColor;
    SKColor *iOSBlueButtonColor;
    //SKLabelNode *playAgainLabel;
}

//Use custom init to pass in playerWin bool and change display accordingly
-(id)initWithSize:(CGSize)size didPlayerWin:(BOOL)playerWin {
    if (self = [super initWithSize:size]) {
        //Set background image. It looks like SpriteKit automatically uses the correct asset for the device type.
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Set sound file to lose by default
        NSString *soundFileName = @"lose.caf";
        
        //Set message based on if player won
        NSString *messageString = @"Sorry, you lost.";
        if (playerWin) {
            messageString = @"Congratulations, you won!";
            soundFileName = @"win.caf";
        }
        
        //Create sound action to play win/lose sound
        SKAction *playSoundAction = [SKAction playSoundFileNamed:soundFileName waitForCompletion:NO];
        [self runAction:playSoundAction];
        
        CGFloat fontSize = 40;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 75;
        }
        
        //Create and set message label
        SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        messageLabel.text = messageString;
        messageLabel.fontColor = [SKColor whiteColor];
        messageLabel.fontSize = fontSize;
        messageLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.6);
        [self addChild:messageLabel];
        
        self.playAgainLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.playAgainLabel.text = @"Try again?";
        self.playAgainLabel.name = @"playAgainLabel";
        self.playAgainLabel.fontColor = iOSBlueButtonColor;
        self.playAgainLabel.fontSize = fontSize;
        self.playAgainLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.4);
        [self addChild:self.playAgainLabel];
        
        changeLabelColor = [SKAction runBlock:^{
            self.playAgainLabel.fontColor = [SKColor greenColor];
        }];
        
        //Create actions to wait and go back to Game Scene
        waitDuration = [SKAction waitForDuration:0.05];
        revealGameScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.playAgainLabel.fontColor = iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorsCloseVerticalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
            [self.view presentScene:myScene transition: reveal];
        }];
        
    }
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    if ([touchedLabel.name isEqual: @"playAgainLabel"]) {
        //Change label color to signify touch
        self.playAgainLabel.fontColor = [SKColor grayColor];
        return;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    if ([touchedLabel.name isEqual: @"playAgainLabel"]) {
        NSLog(@"touch ended");
        [self runAction:[SKAction sequence:@[waitDuration, revealGameScene]]];
        return;
    }
}

@end
