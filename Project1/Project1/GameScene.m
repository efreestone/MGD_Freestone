// Elijah Freestone
// MGD 1411
// Week 1
// October 30th, 2014

//
//  GameScene.m
//  Project1
//
//  Created by Elijah Freestone on 10/30/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameScene.h"

//Create private interface and variable for player fighter jet
@interface GameScene ()
@property (nonatomic) SKSpriteNode *playerFighterJet;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Log out screen size
        NSLog(@"Size = %@", NSStringFromCGSize(size));
        
        //Set background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        //Add the fighter sprite to the scene w/ postion based on width of gfighter and height of frame
        self.playerFighterJet = [SKSpriteNode spriteNodeWithImageNamed:@"fighter"];
        self.playerFighterJet.position = CGPointMake(self.playerFighterJet.size.width, self.frame.size.height/2);
        [self addChild:self.playerFighterJet];
    }
    return self;
}

//Add enemy objects to the scene and ani
-(void)addEnemy {
    
    //Create enemy sprite
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"asteroid-1"];
    
    //Create a random Y axis to spawn enemy
    int minimumY = enemy.size.height / 2;
    int maximumY = self.frame.size.height - enemy.size.height / 2;
    int rangeOfY = maximumY - minimumY;
    int actualYAxis = (arc4random() % rangeOfY) + minimumY;
    
    //Spawn enemy just passed right edge of screen w/ a random Y postion
    enemy.position = CGPointMake(self.frame.size.width + enemy.size.width/2, actualYAxis);
    [self addChild:enemy];
    
    //Determine varied speed of enemies
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //Create the actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-enemy.size.width/2, actualYAxis) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

//-(void)didMoveToView:(SKView *)view {
//    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    [self addChild:myLabel];
//}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    /* Called when a touch begins */
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.xScale = 0.5;
//        sprite.yScale = 0.5;
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
//}
//
//-(void)update:(CFTimeInterval)currentTime {
//    /* Called before each frame is rendered */
//}

@end
