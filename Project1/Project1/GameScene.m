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
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

//Add standard implementations of vector math routines for projectile trajectory
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Log out screen size
        NSLog(@"Size = %@", NSStringFromCGSize(size));
        
        //Set background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        //Add the fighter sprite to the scene w/ postion based on width of gfighter and height of frame
        self.playerFighterJet = [SKSpriteNode spriteNodeWithImageNamed:@"fighter"];
        self.playerFighterJet.position = CGPointMake(75, self.frame.size.height / 2);
        [self addChild:self.playerFighterJet];
    }
    return self;
}

//Add enemy objects to the scene with random speed and spwan point
-(void)addEnemy {
    //Create enemy sprite
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship"];
    
    //Create a random Y axis to spawn enemy
    int minimumY = enemy.size.height / 2;
    int maximumY = self.frame.size.height - enemy.size.height / 2;
    int rangeOfY = maximumY - minimumY;
    int actualYAxis = (arc4random() % rangeOfY) + minimumY;
    
    //Spawn enemy just passed right edge of screen w/ a random Y postion
    enemy.position = CGPointMake(self.frame.size.width + enemy.size.width/2, actualYAxis);
    [self addChild:enemy];
    
    //Determine varied speed of enemies from right to left
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //Create move action from right to left and remove enemy once off screen
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-enemy.size.width/2, actualYAxis) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

//track time since last spawn and add new enemy every 1 second
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addEnemy];
    }
}

//Called by SpriteKit every frame. Checks last update time which in turn spawns enemies.
//This is from Apple's Adventure sample and includes logic to avoid odd behaviour if a large amount of time has passed.
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceUpdate = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceUpdate > 1) { // more than a second since last update
        timeSinceUpdate = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    //Check time since last update and spawn accordingly
    [self updateWithTimeSinceLastUpdate:timeSinceUpdate];
    
}

//Grab touch event and calculate trajectory of projectile.
//Also extends trajectory so the laser ball continues passed the touch and off screen.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Grab touch and location within node
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //Set initial location of projectile to the fighter
    SKSpriteNode *laserBall = [SKSpriteNode spriteNodeWithImageNamed:@"laser-ball"];
    laserBall.position = self.playerFighterJet.position;
    
    //Determine offset of location to fighter
    CGPoint offset = rwSub(location, laserBall.position);
    
    //Bail out if shooting down or backwards
    if (offset.x <= 0) return;
    
    //Position has been double-checked, add laser ball sprite
    [self addChild:laserBall];
    
    //Get the direction of where to shoot laser ball
    CGPoint directionOfShot = rwNormalize(offset);
    
    //Shoot far enough for the laser ball to leave the screen
    CGPoint shootOffScreen = rwMult(directionOfShot, 1000);
    
    //Add the shoot amount to the current position
    CGPoint realDestination = rwAdd(shootOffScreen, laserBall.position);
    
    //Set velocity and create actions for the laser ball
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction *actionMove = [SKAction moveTo:realDestination duration:realMoveDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [laserBall runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

@end
