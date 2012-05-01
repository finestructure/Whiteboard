//
//  EchoLayer.h
//  Whiteboard
//
//  Created by Sven A. Schmidt on 01.05.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "WhiteboardLayer.h"

#import <CouchCocoa/CouchCocoa.h>

@interface EchoLayer : WhiteboardLayer

@property (nonatomic, strong) CouchLiveQuery *events;

@end
