//
//  RootViewController.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 29.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "RootViewController.h"

#import "BonjourBrowser.h"
#import "WhiteboardLayer.h"
#import "Replay.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize canvas = _canvas;
@synthesize popover = _popover;

#pragma mark - Actions


- (IBAction)replayTapped:(id)sender
{
  CCDirector *director = [CCDirector sharedDirector];
  [director end];
  [director.view removeFromSuperview];
  director.view = nil;

  [self setupCocos2D];  
	[director pushScene:[Replay scene]];
  [director startAnimation];
}


- (IBAction)bonjourTapped:(id)sender event:(UIEvent *)event
{
  NSLog(@"bonjour");
  UIView *view = [[event.allTouches anyObject] view];
  BonjourBrowser *bb = [[BonjourBrowser alloc] initForType:@"_http._tcp"
                                                  inDomain:@"local"
                                             customDomains:nil
                                  showDisclosureIndicators:NO
                                          showCancelButton:NO];
  self.popover = [[UIPopoverController alloc] initWithContentViewController:bb];
  [self.popover presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



#pragma mark - Init


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
	[[CCDirector sharedDirector] pushScene:[WhiteboardLayer scene]];
  [[CCDirector sharedDirector] startAnimation];
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
