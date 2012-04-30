//
//  RootViewController.h
//  Whiteboard
//
//  Created by Sven A. Schmidt on 29.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"

@interface RootViewController : UIViewController<CCDirectorDelegate>

@property (nonatomic) IBOutlet UIView *canvas;

- (IBAction)replayTapped:(id)sender;
- (IBAction)bonjourTapped:(id)sender;

@end
