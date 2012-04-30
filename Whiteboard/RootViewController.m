//
//  RootViewController.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 29.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "RootViewController.h"

#import "cocos2d.h"
#import "LineDrawer.h"

@interface RootViewController ()

@end

@implementation RootViewController


- (void)setupCocos2D
{
	CCGLView *glView = [CCGLView viewWithFrame:[self.view bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                 depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view insertSubview:glView atIndex:0];
  [[CCDirector sharedDirector] setView:glView];

  CCScene *scene = [CCScene node];
  [scene addChild:[LineDrawer node]];
	[[CCDirector sharedDirector] pushScene: scene];
  [[CCDirector sharedDirector] startAnimation];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupCocos2D];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
  [[CCDirector sharedDirector] end];
}


- (void)viewWillAppear:(BOOL)animated
{
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
