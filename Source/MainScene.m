//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene
{
    CCSprite *_tapPlay;
}

-(void)onEnter
{
    CCActionFadeIn *fadeInAction = [CCActionFadeIn actionWithDuration:1.0];
    CCActionFadeOut *fadeOutAction = [CCActionFadeOut actionWithDuration:1.0];
    CCActionSequence *actions = [CCActionSequence actions:fadeInAction, fadeOutAction, nil];
    CCActionRepeatForever *action = [CCActionRepeatForever actionWithAction:actions];
    [_tapPlay runAction:action];
    [super onEnter];
}


-(void)play {
    CCLOG(@"play");
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"GameScene"]];
}
@end
