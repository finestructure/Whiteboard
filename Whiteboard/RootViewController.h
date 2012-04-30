//
//  RootViewController.h
//  Whiteboard
//
//  Created by Sven A. Schmidt on 29.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BonjourBrowser.h"
#import "cocos2d.h"

@interface RootViewController : UIViewController<CCDirectorDelegate, BonjourBrowserDelegate>

@property (nonatomic) IBOutlet UIView *canvas;
@property (nonatomic, strong) UIPopoverController *popover;

- (IBAction)replayTapped:(id)sender;
- (IBAction)bonjourTapped:(id)sender event:(UIEvent *)event;

@end
