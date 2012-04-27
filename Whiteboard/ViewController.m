//
//  ViewController.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 25.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "ViewController.h"

#import "LineDrawer.h"


@interface ViewController () {
  CCDirectorIOS *_director; 
}

@end

@implementation ViewController


#pragma mark - Touch event handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"touch began: %@", event);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"touch moved: %@", event);
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"touch ended: %@", event);
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"touch cancelled: %@", event);
}


#pragma mark - Init and view lifecycle


- (void)viewDidLoad
{
  [super viewDidLoad];

  // Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[self.view bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                 depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  
	_director = (CCDirectorIOS*) [CCDirector sharedDirector];
  
	_director.wantsFullScreenLayout = YES;
  
	// Display FSP and SPF
	[_director setDisplayStats:YES];
  
	// set FPS at 60
	[_director setAnimationInterval:1.0/60];
  
	// attach the openglView to the director
	[_director setView:glView];
  
	// for rotation and other messages
	[_director setDelegate:self];
  
	// 2D projection
	[_director setProjection:kCCDirectorProjection2D];
  //	[director setProjection:kCCDirectorProjection3D];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [_director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
  
  [self.view addSubview:_director.view];
  
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
  CCScene *scene = [CCScene node];
  [scene addChild:[LineDrawer node]];
	[_director pushScene: scene]; 
  
}


- (void)viewDidUnload
{
  [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


@end
