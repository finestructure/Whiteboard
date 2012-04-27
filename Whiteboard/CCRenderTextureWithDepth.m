//
//  CCRenderTextureWithDepth.m
//  Whiteboard
//
//  Created by Sven A. Schmidt on 27.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "CCRenderTextureWithDepth.h"

#import "cocos2d.h"


@implementation CCRenderTextureWithDepth {
  GLuint depthRenderBuffer_;
}


- (id)initWithWidth:(int)w height:(int)h andDepthFormat:(GLint)depthFormat
{
  if ((self = [super init])) {
    CCTexture2DPixelFormat format = kCCTexture2DPixelFormat_RGBA8888;
    
    CCDirector *director = [CCDirector sharedDirector];
    
    // XXX multithread
    if ([director runningThread] != [NSThread currentThread])
      CCLOG(@"cocos2d: WARNING. CCRenderTexture is running on its own thread. Make sure that an OpenGL context is being used on this thread!");
    
    w *= CC_CONTENT_SCALE_FACTOR();
    h *= CC_CONTENT_SCALE_FACTOR();
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO_);
    
    // textures must be power of two
    NSUInteger powW;
    NSUInteger powH;
    
    if ([[CCConfiguration sharedConfiguration] supportsNPOT]) {
      powW = w;
      powH = h;
    } else {
      powW = ccNextPOT(w);
      powH = ccNextPOT(h);
    }
    
    void *data = malloc((int)(powW * powH * 4));
    memset(data, 0, (int)(powW * powH * 4));
    pixelFormat_ = format;
    
    texture_ = [[CCTexture2D alloc] initWithData:data pixelFormat:pixelFormat_ pixelsWide:powW pixelsHigh:powH contentSize:CGSizeMake(w, h)];
    free(data);
    
    //! we need to remember old render buffer to restore it later/ bug in cocos2d ?
    GLint oldRBO;
    glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);
    
    // generate FBO
    glGenFramebuffers(1, &fbo_);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
    
    // associate texture with FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture_.name, 0);
    
    //create and attach depth buffer
    glGenRenderbuffers(1, &depthRenderBuffer_);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer_);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, powW, powH);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer_);
    
    // check if it worked (probably worth doing :) )
    NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");
    
    [texture_ setAliasTexParameters];
    
    sprite_ = [CCSprite spriteWithTexture:texture_];
    
    [sprite_ setScaleY:-1];
    [self addChild:sprite_];
    
    // issue #937
    [sprite_ setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
    
    //! restore rbo
    glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO_);
  }
  return self;
}


- (void)dealloc
{
  glDeleteRenderbuffers(1, &depthRenderBuffer_);
}


@end


