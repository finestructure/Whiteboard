//
//  RootViewController.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 29.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "RootViewController.h"

#import "WhiteboardLayer.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize canvas = _canvas;

- (void)setupCocos2D
{
	CCGLView *glView = [CCGLView viewWithFrame:[self.canvas bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                 depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.canvas insertSubview:glView atIndex:0];

  CCDirector *director = [CCDirector sharedDirector];
  director.view = glView;
  director.displayStats = YES;
  director.animationInterval = 1/60.;
  director.delegate = self;
  director.projection = kCCDirectorProjection2D;
	if(! [director enableRetinaDisplay:YES]) {
		CCLOG(@"Retina Display Not supported");
  }

	[director pushScene:[WhiteboardLayer scene]];
  [director startAnimation];
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
  [self setCanvas:nil];
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
