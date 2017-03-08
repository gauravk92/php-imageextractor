//
//  NSImage-CGImageConversion.m
//  imageextractor
//
//  Created by Gaurav Khanna on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSImage-CGImageConversions.h"

@implementation NSImage (CGImageConversion)

- (NSBitmapImageRep *)bitmap {
	// returns a 32-bit bitmap rep of the receiver, whatever its original format. The image rep is not added to the image.
	
	NSSize size = [self size];
    
	int rowBytes = ((int)(ceil(size.width)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned
    
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
                                                                         pixelsWide:size.width 
                                                                         pixelsHigh:size.height 
                                                                      bitsPerSample:8 
                                                                    samplesPerPixel:4 
                                                                           hasAlpha:YES 
                                                                           isPlanar:NO 
                                                                     colorSpaceName:NSCalibratedRGBColorSpace 
                                                                       bitmapFormat:0 
                                                                        bytesPerRow:rowBytes 
                                                                       bitsPerPixel:32];
    
	if ( imageRep == NULL )
		return NULL;
	
	NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	[self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	
	[NSGraphicsContext restoreGraphicsState];
	
	return [imageRep autorelease];
}

static void BitmapReleaseCallback( void* info, const void* data, size_t size )
{
	NSBitmapImageRep* bm = (NSBitmapImageRep*)info;
	[bm release];
}

- (CGImageRef)cgImage {
	NSBitmapImageRep*	bm = [[self bitmap] retain]; // data provider will release this
	int					rowBytes, width, height;
	
	rowBytes = [bm bytesPerRow];
	width = [bm pixelsWide];
	height = [bm pixelsHigh];
    
	CGDataProviderRef provider = CGDataProviderCreateWithData( bm, [bm bitmapData], rowBytes * height, BitmapReleaseCallback );
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
	CGBitmapInfo	bitsInfo = kCGImageAlphaLast;
	
	CGImageRef img = CGImageCreate( width, height, 8, 32, rowBytes, colorspace, bitsInfo, provider, NULL, NO, kCGRenderingIntentDefault );
	
	CGDataProviderRelease( provider );
	CGColorSpaceRelease( colorspace );
	
	return img;
}

@end
