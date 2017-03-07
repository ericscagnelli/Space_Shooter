//
//  GameScene.m
//  p04-scagnelli
//
//  Created by Eric Scagnelli on 2/28/17.
//  Copyright © 2017 escagne1. All rights reserved.
//
//  Most code in this project is heavily based on Sprite Kit Tutorial: Space Shooter
//  Which can be found at https://www.raywenderlich.com/49625/sprite-kit-tutorial-space-shooter
//

#import <CoreMotion/CoreMotion.h>
#import "GameScene.h"
#import "FMMParallaxNode.h"

@implementation GameScene {
    SKSpriteNode *ship;
    FMMParallaxNode *parallaxNodeBackgrounds;
    FMMParallaxNode *parallaxNodeSpaceDust;
    CMMotionManager *motionManager;
}

-(id)initWithSize:(CGSize)size{
    
    self = [super initWithSize:size];
    if(self){
        NSLog(@"The size of the game scene is %f x %f", size.width, size.height);
        
        self.backgroundColor = [UIColor blackColor];
        
        //Make physics body around the screen so the ship cannot fall off.
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
#pragma mark - Game Backgrounds
        NSArray *backgroundNames = @[@"bg_galaxy.png", @"bg_planetsunrise.png",
                                     @"bg_spacialanomaly.png", @"bg_spacialanomaly2.png"];
        
        CGSize planetSize = CGSizeMake(200, 200);
        parallaxNodeBackgrounds = [[FMMParallaxNode alloc] initWithBackgrounds:backgroundNames size:planetSize pointsPerSecondSpeed:10];
        
        parallaxNodeBackgrounds.position = CGPointMake(size.width/2, size.height/2);
        [parallaxNodeBackgrounds randomizeNodesPositions];
        
        [self addChild:parallaxNodeBackgrounds];
        
        NSArray *secondBackgroundNames = @[@"bg_front_spacedust.png",@"bg_front_spacedust.png"];
        parallaxNodeSpaceDust = [[FMMParallaxNode alloc] initWithBackgrounds:secondBackgroundNames
                                                size:size pointsPerSecondSpeed:25];
        
        parallaxNodeSpaceDust.position = CGPointMake(0, 0);
        [self addChild:parallaxNodeSpaceDust];
        
#pragma mark - Setup Sprite for the ship
        ship = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceFlier_sm_1.png"];
        ship.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
        
        ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ship.frame.size];
        ship.physicsBody.dynamic = YES; //Subject to collisions and outside forces
        ship.physicsBody.affectedByGravity = NO;
        ship.physicsBody.mass = .02;  //arbitrary mass to make movement feel natural.
        
        
        [self addChild:ship];
        
#pragma mark - TBD - Setup the asteroids
        
#pragma mark - TBD - Setup the lasers
        
#pragma mark - Setup the Accelerometer to move the ship
        motionManager = [[CMMotionManager alloc] init];
        
#pragma mark - Setup the stars to appear as particles
        [self addChild:[self loadEmitterNode:@"stars1"]];
        [self addChild:[self loadEmitterNode:@"stars2"]];
        [self addChild:[self loadEmitterNode:@"stars3"]];
        
#pragma mark - Start the actual game
        [self startTheGame];
    }
    return self;
}

-(SKEmitterNode *) loadEmitterNode:(NSString *)fileName{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width+100, self.size.height);
    
    return emitterNode;
}

-(void)startTheGame{
    ship.hidden = NO;
    ship.position = CGPointMake(self.frame.size.width * .1, CGRectGetMidY(self.frame));
    
    [self startMonitoringAcceleration];
}

- (void)startMonitoringAcceleration{
    if (motionManager.accelerometerAvailable) {
        [motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration{
    if (motionManager.accelerometerAvailable && motionManager.accelerometerActive) {
        [motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

- (void)updateShipPositionFromMotionManager{
    CMAccelerometerData* data = motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        [ship.physicsBody applyForce:CGVectorMake(0.0, 50 * (data.acceleration.x + .5))];
        NSLog(@"Acceleration is %f", data.acceleration.x + .5);
    }
}

-(void)update:(NSTimeInterval)currentTime{
    [parallaxNodeBackgrounds update:currentTime];
    [parallaxNodeSpaceDust update:currentTime];
    [self updateShipPositionFromMotionManager];
}

@end
