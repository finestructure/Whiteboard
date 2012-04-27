//
//  CouchPoint.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 27.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "WBEvent.h"

#import "Globals.h"

@implementation WBEvent

@dynamic x, y, index, type, state;


- (id)initWithNewDocumentInDatabase:(CouchDatabase *)database
{
  self = [super initWithNewDocumentInDatabase:database];
  if (self) {
    self.type = @"event";
  }
  return self;
}


- (void)setPosition:(CGPoint)pos {
  self.x = [NSNumber numberWithDouble:pos.x];
  self.y = [NSNumber numberWithDouble:pos.y];
}


- (CGPoint)position {
  CGPoint p = CGPointMake([self.x doubleValue], [self.y doubleValue]);
  return p;
}
}


@end
