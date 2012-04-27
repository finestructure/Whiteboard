//
//  AppDelegate.h
//  Whiteboard
//
//  Created by Sven A. Schmidt on 25.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;  
	CCDirectorIOS	*__unsafe_unretained director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (unsafe_unretained, readonly) CCDirectorIOS *director;

@end
