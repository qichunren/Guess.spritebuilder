//
//  GameScene.m
//  Guess
//
//  Created by qichunren on 8/5/14.
//  Copyright 2014年 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "Mask.h"
#import "Target.h"
#import "NSMutableArray+Convenience.h"

static int maskSize = 4;
static CCTime moveSpeed = 0.4;

typedef enum {
    SHUFFLE,
    GUSSING,
    FINISHED
} GameStatus;

@implementation GameScene
{
    int _targetIndex;
    int _movingCount;
    int _moveSteps;

    Target * _target;
    NSMutableArray * _maskArray;
    NSMutableArray * _positionArray;
    NSMutableArray * _startPositionArray;
    GameStatus _gameStatus;
    CCSprite *_playAgain;
    
}

-(void)onEnter
{
    CCLOG(@"on enter");
    _maskArray = [NSMutableArray array];
    _positionArray = [NSMutableArray array];
    _startPositionArray =[NSMutableArray array];
    _moveSteps = 3;
    _gameStatus = SHUFFLE;
    _playAgain.zOrder = 9999;
    
    [self initElements];
    [self addTarget];
    [self addMasks];
    self.userInteractionEnabled = YES;
    [super onEnter];
}

-(void)initElements
{
    CGSize size = self.contentSizeInPoints;
    CCLOG(@"size: w:%f, h:%f", size.width, size.height);
    CGFloat padding = 80;
    CGFloat offset = (size.width - padding * 2) / maskSize;
    
    for (int i=0; i < maskSize; i++) {
        Mask * mask = (Mask *)[CCBReader load:@"mask"];
        [_maskArray addObject:mask];
        CGPoint startPoint = ccp(offset+offset*i, size.height-20);
        CGPoint point = ccp(offset+offset*i, size.height/2-40);
        CCLOG(@"point: x:%f, y:%f", point.x, point.y);
        NSValue *pointValue = [NSValue valueWithCGPoint:point];
        NSValue *startPointValue = [NSValue valueWithCGPoint:startPoint];
        [_positionArray addObject: pointValue];
        [_startPositionArray addObject:startPointValue];
    }
}

-(void) addTarget
{
    _targetIndex = [self randomIndex];
    [self addTargetAt: _targetIndex];
}

-(void) addTargetAt:(int)index{
    _target.zOrder = 11;
    NSValue *pointValue = [_positionArray objectAtIndex: index];
    CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:0.5 position:[pointValue CGPointValue]];
    [_target runAction:moveAction];
}

-(void)addMasks
{
    [self scheduleBlock:^(CCTimer *timer){
        for (int i=0; i < maskSize; i++) {
            Mask * mask = _maskArray[i];
            if (_targetIndex == i) {
                mask.maskTarget = true;
            }else {
                mask.maskTarget = false;
            }
            [self addMask:mask at:i];
        }
        [_target setVisible:false];
    } delay:2.5];
    
}

-(void) addMask:(Mask*)mask at:(int)index{
    [self addChild:mask z:12];
    NSValue *pointValue = [_positionArray objectAtIndex: index];
    CGPoint point = [pointValue CGPointValue];
    
    NSValue *startPointValue = [_startPositionArray objectAtIndex: index];
    CGPoint startPoint = [startPointValue CGPointValue];
    
    [mask setPosition:startPoint];
    CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:0.3 position:point];
    CCActionCallFunc *callFuction = [CCActionCallFunc actionWithTarget:self selector:@selector(startShuffle)];
    CCActionSequence *actions = [CCActionSequence actions:moveAction, callFuction, nil];
    [mask runAction:actions];
}

-(void)startShuffle
{
    [self schedule:@selector(shuffle) interval:(moveSpeed+moveSpeed/2) repeat:_moveSteps delay:0.4];
}

-(int)randomIndex{
    return arc4random() % maskSize;
}

-(int)randomSwitchIndex{
    
    return arc4random() % (maskSize-1);
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
	// Touch to guess the target
    CGPoint touchLocation = [touch locationInNode:self];
    CCLOG(@"Touch location: x:%f  y:%f", touchLocation.x, touchLocation.y);
    if (_gameStatus == GUSSING) {
        for (int i=0; i<maskSize; i++) {
            Mask * mask = _maskArray[i];
            CGRect maskRect = mask.boundingBox;
            if (CGRectContainsPoint(maskRect, touchLocation)) {
                CCLOG(@"touched %d mask", i);
                
                if (mask.maskTarget) {
                    _gameStatus = FINISHED;
                    
                    NSValue *pointValue = [_startPositionArray objectAtIndex: i];
                    CGPoint point = [pointValue CGPointValue];
                    
                    CCActionJumpTo * jumpAction = [CCActionJumpTo actionWithDuration:0.5 position:point height:80 jumps:1];
                    [mask runAction:jumpAction];
                    [_target setVisible:true];
                    CCActionScaleTo *actionScale = [CCActionScaleTo actionWithDuration:0.5 scale:1.2];
                    [_target runAction:actionScale];
                    
                    CCNode *explosion = [CCBReader load:@"WinStar"];
                    explosion.position = mask.position;
                    [self addChild:explosion];
                    CCActionDelay *delayAction = [CCActionDelay actionWithDuration:3.0];
                    CCActionFadeOut *removeAction = [CCActionRemove action];
                    CCActionSequence *action = [CCActionSequence actions:delayAction, removeAction, nil];
                    [explosion runAction:action];
                    
                    [self scheduleBlock:^(CCTimer *timer) {
                        [_playAgain setVisible:true];
                    } delay:1.0];
                }else{
                    // Failed, game again.
                    CCActionJumpTo * jumpAction = [CCActionJumpTo actionWithDuration:0.5 position:mask.position height:80 jumps:1];
                    [mask runAction:jumpAction];
                }
            }
        }
    }

    if (_gameStatus == FINISHED && _playAgain.visible) {
        if (CGRectContainsPoint(_playAgain.boundingBox, touchLocation)) {
            [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"GameScene"]];
        }
    }

}

-(void)shuffle
{
    int switchIndex = [self randomSwitchIndex];
    CCLOG(@"switch index:%d", switchIndex);
    [self moveMasksAtIndex: switchIndex];
    _moveSteps -= 1;
    if (_moveSteps == -1) {
        _gameStatus = GUSSING;
    }
}

-(void)moveMasksAtIndex:(int)index {
    Mask *aMask, *bMask;
    aMask = _maskArray[index];
    bMask = _maskArray[index+1];
    
    NSValue *pointValueA = [_positionArray objectAtIndex: index];
    NSValue *pointValueB = [_positionArray objectAtIndex: index+1];
    CGPoint aPoint = [pointValueA CGPointValue];
    CGPoint bPoint = [pointValueB CGPointValue];
    
    if (aMask.maskTarget) {
        [_target setPosition:bPoint];
    }else if (bMask.maskTarget){
        [_target setPosition:aPoint];
    }
    
    [_maskArray moveObjectAtIndex:index toIndex:(index+1)];

    CCActionMoveTo * moveAction = [CCActionMoveTo actionWithDuration:moveSpeed position: bPoint];
    [aMask runAction:moveAction];
    
    
    CCActionMoveTo * moveAction1 = [CCActionMoveTo actionWithDuration:moveSpeed position: aPoint];
    [bMask runAction:moveAction1];
}


@end
