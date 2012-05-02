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
#import "LinePoint.h"
#import "WBEvent.h"


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
    [self.events start];
  }
  return self;
}


- (void)dealloc
{
  [self.events removeObserver:self forKeyPath:@"rows"];
}


#pragma mark - KVO


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"rows"]) {
    NSLog(@"change: %@", change);
    CouchQueryEnumerator *newRows = [change valueForKey:NSKeyValueChangeNewKey];
    CouchQueryRow *row;
    while ((row = newRows.nextRow)) {
      WBEvent *event = [WBEvent modelForDocument:row.document];
      NSLog(@"processing event %@", event.index);
      [self processEvent:event];
    }
  }
}


#pragma mark - Touch event handling


- (CGPoint)getPoint:(WBEvent *)event {
  return [[CCDirector sharedDirector] convertToGL:event.position];
}


- (void)processEvent:(WBEvent *)event {
  switch ([event.phase unsignedIntegerValue]) {
    case UITouchPhaseBegan:
      [self touchBegan:event];
      break;
      
    case UITouchPhaseMoved:
      [self touchMoved:event];
      break;
      
    case UITouchPhaseEnded:
      [self touchEnded:event];
      break;
      
    case UITouchPhaseCancelled:
      [self touchCancelled:event];
      break;
      
    default:
      break;
  }
}


- (BOOL)touchBegan:(WBEvent *)event {
  CGPoint point = [self getPoint:event];
  
  [self.points removeAllObjects];
  [self.velocities removeAllObjects];
  
  [self startNewLineFrom:point withSize:self.penWidth];
  [self addPoint:point withSize:self.penWidth];
  [self addPoint:point withSize:self.penWidth];
  
  return YES;
}


- (void)touchMoved:(WBEvent *)event {
  CGPoint point = [self getPoint:event];
  float eps = 1.5f;
  if ([self.points count] > 0) {
    float length = ccpLength(ccpSub([(LinePoint *)[self.points lastObject] pos], point));
    
    if (length < eps) {
      return;
    }
  }
  //TODO: vary size
  [self addPoint:point withSize:self.penWidth];
}


- (void)touchEnded:(WBEvent *)event {
  CGPoint point = [self getPoint:event];
  //TODO: vary size
  [self endLineAt:point withSize:self.penWidth];
  [self draw];
}


- (void)touchCancelled:(WBEvent *)event {
  [self draw];
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
