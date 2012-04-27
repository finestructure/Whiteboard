//
//  CCRenderTextureWithDepth.h
//  Whiteboard
//
//  Created by Sven A. Schmidt on 27.04.12.
//  Copyright (c) 2012 abstracture GmbH & Co. KG. All rights reserved.
//

#import "CCRenderTexture.h"

@interface CCRenderTextureWithDepth : CCRenderTexture

- (id)initWithWidth:(int)w height:(int)h andDepthFormat:(GLint)depthFormat;

@end
