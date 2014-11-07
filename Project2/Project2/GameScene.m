// Elijah Freestone
// MGD 1411
// Week 1
// November 3rd, 2014

//
//  GameScene.m
//  Project2
//
//  Created by Elijah Freestone on 11/3/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

//Set up category constants for laser balls and enemy spaceships
//SpriteKit uses 32 bit ints that act as bitmasks
static const uint32_t laserBallCategory =  0x1 << 0;
static const uint32_t enemyShipCategory =  0x1 << 1;

//Create private interface and variables
@interface GameScene () <SKPhysicsContactDelegate>
@property (strong, nonatomic) SKSpriteNode *playerFighterJet;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (strong, nonatomic) SKLabelNode *livesLabel;
@property (strong, nonatomic) NSMutableArray *explosionTextures;

@end

//Add standard implementations of vector math routines for projectile trajectory.
//These are from a raywenderlich.com SpriteKite tutorial
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


@implementation GameScene {
    //Declare sound actions to be loaded ahead of time
    SKAction *laserSoundAction;
    SKAction *hitEnemySoundAction;
    SKAction *missShipSoundAction;
    
    SKSpriteNode *laserBallNode;
    SKSpriteNode *enemyShipNode;
    int enemyShipsDestroyed;
    int playerLives;
    CGFloat angle;
    float fontSize;
    float explosionScale;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Load explosion atlas with images in order after sort via compare
        SKTextureAtlas *explosionTextureAtlas = [SKTextureAtlas atlasNamed:@"explosion"];
        NSArray *textureNamesArray = [[explosionTextureAtlas textureNames] sortedArrayUsingSelector: @selector(compare:)];
        self.explosionTextures = [NSMutableArray new];
        
        for (NSString *name in textureNamesArray) {
            SKTexture *texture = [explosionTextureAtlas textureNamed:name];
            [self.explosionTextures addObject:texture];
        }
        
        //Log out screen size
        NSLog(@"Size = %@", NSStringFromCGSize(size));
        
        //Set background image. It looks like SpriteKit automatically uses the correct asset for the device type.
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"space"];
        backgroundImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:backgroundImage];
        
        //Set font size and adjust for ipad
        fontSize = 15;
        explosionScale = 0.5;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize = 30;
            explosionScale = 1;
        }
        
        //Add the fighter sprite to the scene w/ postion based on width of fighter and height of frame
        self.playerFighterJet = [SKSpriteNode spriteNodeWithImageNamed:@"fighter"];
        self.playerFighterJet.position = CGPointMake(self.playerFighterJet.size.width * 0.75, self.frame.size.height / 2);
        [self addChild:self.playerFighterJet];
        
        //Set up physics world with zero gravity
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //Set lives and ship count
        playerLives = 3;
        enemyShipsDestroyed = 0;
        
        //Create and display score label
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        //Fixed issue with ships not showing by setting their zPosition higher than the labels (0.0 default)
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", enemyShipsDestroyed];
        self.scoreLabel.fontColor = [SKColor whiteColor];
        self.scoreLabel.fontSize = fontSize;
        //self.scoreLabel.zPosition = 1;
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.scoreLabel.position = CGPointMake(50, 15);
        [self addChild:self.scoreLabel];
        //Create and display lives label
        self.livesLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
        self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d", playerLives];
        self.livesLabel.fontColor = [SKColor whiteColor];
        self.livesLabel.fontSize = fontSize;
        //self.livesLabel.zPosition = 1;
        self.livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.livesLabel.position = CGPointMake(self.size.width / 2, 15);
        [self addChild:self.livesLabel];
        
        //Initiate sounds for laser fire, hitting and missing an enemy spaceship
        //Sounds for winning/losing a game are created and played on GameOverScene
        laserSoundAction = [SKAction playSoundFileNamed:@"laser.caf" waitForCompletion:NO];
        hitEnemySoundAction = [SKAction playSoundFileNamed:@"explosion.caf" waitForCompletion:NO];
        missShipSoundAction = [SKAction playSoundFileNamed:@"miss.caf" waitForCompletion:NO];
    }
    return self;
}

//Add enemy objects to the scene with random speed and spawn points (Y axis)
-(void)addEnemyShip {
    //Create enemy sprite
    enemyShipNode = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship"];
    enemyShipNode.zPosition = 4;
    //Set physics body to radius around enemy spaceship
    enemyShipNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemyShipNode.size.width / 2];
    enemyShipNode.physicsBody.dynamic = YES;
    //Set category, contact and collision
    enemyShipNode.physicsBody.categoryBitMask = enemyShipCategory;
    enemyShipNode.physicsBody.contactTestBitMask = laserBallCategory;
    enemyShipNode.physicsBody.collisionBitMask = 0; // 5
    
    //Create a random Y axis to spawn enemy
    int minimumY = enemyShipNode.size.height / 2;
    int maximumY = self.frame.size.height - enemyShipNode.size.height / 2;
    int rangeOfY = maximumY - minimumY;
    int actualYAxis = (arc4random() % rangeOfY) + minimumY;
    
    //Spawn enemy just passed right edge of screen w/ a random Y postion
    enemyShipNode.position = CGPointMake(self.frame.size.width + enemyShipNode.size.width/2, actualYAxis);
    [self addChild:enemyShipNode];
    
    //Determine varied speed of enemies from right to left
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //Create move action from right to left and remove enemy once off screen
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-enemyShipNode.size.width/2, actualYAxis) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    //[enemyShip runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    //Create loseAction with block to show Game Over Scene if an enemy get by
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *revealGameLost = [SKTransition doorsOpenVerticalWithDuration:0.5];
        SKScene * gameLostScene = [[GameOverScene alloc] initWithSize:self.size didPlayerWin:NO];
        //Play missed ship sound
        [self runAction:missShipSoundAction];
        //Remove lives as spaceships are missed
        playerLives--;
        self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d", playerLives];
        //3 ships missed, player lost
        if (playerLives == 0) {
            [self.view presentScene:gameLostScene transition: revealGameLost];
        }
    }];
    //Make sure spaceship exists
    if (enemyShipNode != nil) {
        [enemyShipNode runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    } else {
        NSLog(@"enemyShipNode NIL!");
    }
}

-(void)addLaserBall {
    //Set initial location of projectile to the fighter
    laserBallNode = [SKSpriteNode spriteNodeWithImageNamed:@"laser-ball"];
    laserBallNode.zPosition = 4;
    laserBallNode.position = self.playerFighterJet.position;
    laserBallNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:laserBallNode.size.width/2];
    laserBallNode.physicsBody.dynamic = YES;
    //Set category, contact and collision
    laserBallNode.physicsBody.categoryBitMask = laserBallCategory;
    laserBallNode.physicsBody.contactTestBitMask = enemyShipCategory;
    laserBallNode.physicsBody.collisionBitMask = 0;
    laserBallNode.physicsBody.usesPreciseCollisionDetection = YES;
    
}

//track time since last spawn and add new enemy every 1 second
- (void)timeSinceLastSpawn:(CFTimeInterval)timeSinceUpdate {
    self.lastSpawnTimeInterval += timeSinceUpdate;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addEnemyShip];
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
    [self timeSinceLastSpawn:timeSinceUpdate];
    
}

//Grab touch event and calculate trajectory of projectile.
//Also extends trajectory so the laser ball continues passed the touch and off screen.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Grab touch and location within node
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //Call method to add laser ball
    [self addLaserBall];
    
    //Determine offset of location to fighter
    CGPoint offset = rwSub(location, laserBallNode.position);
    
    //Make sure not shooting backwards or up/down
    if (offset.x <= 0) return;
    
    //Position has been double-checked, add laser ball sprite
    [self addChild:laserBallNode];
    
    //Get the direction of where to shoot laser ball
    //rwNormalize is a unit vector of length 1
    CGPoint directionOfShot = rwNormalize(offset);
    
    //Shoot far enough for the laser ball to leave the screen
    CGPoint shootOffScreen = rwMult(directionOfShot, 1000);
    
    //Add the shoot amount to the current position
    CGPoint finalDestination = rwAdd(shootOffScreen, laserBallNode.position);
    
    //Calculate velocity multiplier based on device type. Increased for iPad to compensate for larger screen
    float velocityMultiplier = 1.0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        velocityMultiplier = 2.5;
    }
    
    //Set velocity and create actions for the laser ball
    float velocity = 400.0 * velocityMultiplier;
    float realMoveDuration = self.size.width / velocity;
    SKAction *actionShoot = [SKAction moveTo:finalDestination duration:realMoveDuration];
    SKAction *actionShootDone = [SKAction removeFromParent];
    //Make sure laser ball exists
    if (laserBallNode != nil) {
        [laserBallNode runAction:[SKAction sequence:@[actionShoot, actionShootDone]]];
    } else {
        NSLog(@"laserBallNode NIL!");
    }
    
    //Get angle of shot and rotate fighter accordingly
    float deltaX = self.playerFighterJet.position.x - location.x;
    float deltaY = self.playerFighterJet.position.y - location.y;
    //Adding pi rotates the fight 180 to point the correct direction.
    angle = atan2(deltaY, deltaX) + M_PI;
    SKAction *rotateFighter = [SKAction rotateToAngle:angle duration:0.1 shortestUnitArc:YES];
    [self.playerFighterJet runAction:rotateFighter];
    
    //Play laser fire sound
    [self runAction:laserSoundAction];
}

//Contact delegate method. Triggers removal method when collision is detected
-(void)didBeginContact:(SKPhysicsContact *)contact {
    //Set physics bodies w/ generic names.
    SKPhysicsBody *firstBody, *secondBody;
    //Order is not gauranteed so sort by category
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    //Call remove method if physics bodies are laserBall and enemyShip
    if ((firstBody.categoryBitMask & laserBallCategory) != 0 && (secondBody.categoryBitMask & enemyShipCategory) != 0) {
        [self laserBall:(SKSpriteNode *)firstBody.node didCollideWithEnemyShip:(SKSpriteNode *)secondBody.node];
        //Play explosion sound
        [self runAction:hitEnemySoundAction];
    }
}

//Remove ship and laser ball when collision detected
-(void)laserBall:(SKSpriteNode *)passedLaserBall didCollideWithEnemyShip:(SKSpriteNode *)passedEnemyShip {
    NSLog(@"Hit");
    
    //Add explosion to scenen
    SKSpriteNode *explosionNode = [SKSpriteNode spriteNodeWithTexture:[self.explosionTextures objectAtIndex:0]];
    explosionNode.scale = explosionScale;
    explosionNode.position = passedEnemyShip.position;
    [self addChild:explosionNode];
    
    SKAction *explosionAction = [SKAction animateWithTextures:self.explosionTextures timePerFrame:0.05];
    SKAction *removeExplosion = [SKAction removeFromParent];
    [explosionNode runAction:[SKAction sequence:@[explosionAction, removeExplosion]]];
    
    SKAction *delayRemove = [SKAction waitForDuration:0.0025];
    SKAction *removeSpriteNodes = [SKAction runBlock:^{
        //Remove nodes that collided
        [passedLaserBall removeFromParent];
        [passedEnemyShip removeFromParent];
    }];
    
    //Delay removal of sprites. This is to help smooth how the removal looks
    [self runAction:[SKAction sequence:@[delayRemove, removeSpriteNodes]]];
    
    //Keep track of enemy ships destroyed and update score
    enemyShipsDestroyed++;
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", enemyShipsDestroyed]];
    //Reveal game won scene once 15 ships destroyed
    if (enemyShipsDestroyed >= 15) {
        SKTransition *revealGameWon = [SKTransition doorsOpenVerticalWithDuration:0.5];
        SKScene *gameWonScene = [[GameOverScene alloc] initWithSize:self.size didPlayerWin:YES];
        [self.view presentScene:gameWonScene transition:revealGameWon];
    }
}

@end
