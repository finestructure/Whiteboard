//
//  EchoLayer.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 01.05.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "EchoLayer.h"

#import "cocos2d.h"

#import "Database.h"


@implementation EchoLayer

@synthesize events = _events;

+ (CCScene *)scene
{
  CCScene *scene = [CCScene node];
  EchoLayer *layer = [EchoLayer node];
  [scene addChild:layer];
  return scene;
}


- (id)init
{
  self = [super init];
  if (self) {
    self.isTouchEnabled = NO;
    
    self.events = [[[Database sharedInstance] events] asLiveQuery];
    [self.events addObserver:self forKeyPath:@"rows" options:NSKeyValueObservingOptionNew context:nil];
  }
  return self;
}


#pragma mark - KVO


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"rows"]) {
    NSLog(@"change: %@", change);
  }
}


#pragma mark - Touch event delegates


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
}



@end
