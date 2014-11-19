// Elijah Freestone
// MGD 1411
// Week 4
// November 18th, 2014

//
//  MainMenuScene.m
//  Project4
//
//  Created by Elijah Freestone on 11/18/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"
#import "HowToScene.h"

@implementation MainMenuScene {
    SKAction *waitDuration;
    SKAction *revealGameScene;
    SKAction *changeLabelColor;
    
    SKAction *revealHowToScene;
    SKAction *revealAboutScene;
    
    SKColor *iOSBlueButtonColor;
    
    //SKLabelNode *touchedLabel;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set color similar to the blue of default iOS button
        iOSBlueButtonColor = [SKColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        
        //Adjust font size based on device
        CGFloat fontSize = 40;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 75;
        }
        
        //Create and set message label
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        titleLabel.text = @"AstroBlaster";
        titleLabel.fontColor = [SKColor whiteColor];
        titleLabel.fontSize = fontSize * 0.75;
        float titleLabelHeightPlus = titleLabel.frame.size.height + fontSize / 2;
        titleLabel.position = CGPointMake(self.size.width / 2, self.size.height - titleLabelHeightPlus);
        [self addChild:titleLabel];
        
        //Create play button label
        self.playButtonLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.playButtonLabel.text = @"Play Game";
        self.playButtonLabel.name = @"playButtonLabel";
        self.playButtonLabel.fontColor = iOSBlueButtonColor;
        self.playButtonLabel.fontSize = fontSize;
        self.playButtonLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.65);
        [self addChild:self.playButtonLabel];
        
        //Create how to (tutorial) button label
        self.howToPlayLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.howToPlayLabel.text = @"How To Play";
        self.howToPlayLabel.name = @"howToPlayLabel";
        self.howToPlayLabel.fontColor = iOSBlueButtonColor;
        self.howToPlayLabel.fontSize = fontSize;
        self.howToPlayLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.5);
        [self addChild:self.howToPlayLabel];
        
        //Create about button label
        self.aboutLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.aboutLabel.text = @"About";
        self.aboutLabel.name = @"aboutLabel";
        self.aboutLabel.fontColor = iOSBlueButtonColor;
        self.aboutLabel.fontSize = fontSize;
        self.aboutLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.35);
        [self addChild:self.aboutLabel];
        
        //Alloc scenes
        SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
        SKScene *howToScene = [[HowToScene alloc] initWithSize:self.size];
        
        //Create actions to wait and go to appropriate scene
        waitDuration = [SKAction waitForDuration:0.05];
        revealGameScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.playButtonLabel.fontColor = iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:gameScene transition: reveal];
        }];
        revealHowToScene = [SKAction runBlock:^{
            //Change label back to iOS blue
            self.howToPlayLabel.fontColor = iOSBlueButtonColor;
            SKTransition *reveal = [SKTransition doorsCloseHorizontalWithDuration:0.5];
            [self.view presentScene:howToScene transition: reveal];
        }];
    
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    
    //Play button label
    if ([touchedLabel.name isEqual: @"playButtonLabel"]) {
        //NSLog(@"touch ended");
        self.playButtonLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //How to button label
    if ([touchedLabel.name isEqual: @"howToPlayLabel"]) {
        self.howToPlayLabel.fontColor = [SKColor grayColor];
        return;
    }
    
    //About button label
    if ([touchedLabel.name isEqual: @"aboutLabel"]) {
        self.aboutLabel.fontColor = [SKColor grayColor];
        return;
    }
}

//Touch end. Check label
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //Check if touch point is Try Again label
    SKNode *touchedLabel = [self nodeAtPoint:location];
    NSLog(@"Label: %@", touchedLabel.name);
    //Play button label
    if ([touchedLabel.name isEqual: @"playButtonLabel"]) {
        //NSLog(@"touch ended");
        [self runAction:[SKAction sequence:@[waitDuration, revealGameScene]]];
        return;
    }
    
    //How to button label
    if ([touchedLabel.name isEqual: @"howToPlayLabel"]) {
        [self runAction:[SKAction sequence:@[waitDuration, revealHowToScene]]];
        return;
    }
    
    //About button label
    if ([touchedLabel.name isEqual: @"aboutLabel"]) {
    
        return;
    }

}

@end
