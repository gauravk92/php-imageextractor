#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import "NSImage-CGImageConversions.h"

typedef struct _RGBPixel {
    unsigned char redByte, greenByte, blueByte; 
} RGBPixel;

typedef struct _RGBAPixel {
    unsigned char redByte, greenByte, blueByte, alphaByte;  
} RGBAPixel;

void ExportImage(CGImageRef image, const char *str) {
    CFStringRef str2 = CFStringCreateWithCString(NULL, str, kCFStringEncodingUTF8);
    
	CFURLRef url = CFURLCreateWithString( NULL, str2, NULL);
    
	CFStringRef type = kUTTypePNG;  //public.png
	size_t count = 1; 
	CFDictionaryRef options = NULL;
	CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, type, count, options);
    
	CGImageDestinationAddImage(dest, image, NULL);
    
	CGImageDestinationFinalize(dest);
	CFRelease(dest);
}
//-------------------------------------------------------------------------------------
/*void DrawOffscreen(CGContextRef ctx) {
 CGContextSaveGState(ctx);
 
 CGRect shapeBounds = {10, 10, 200, 200};
 
 const float mFillColor[4] = {0.0,  1.0,  0.0,  1.0};
 CGContextSetFillColor(ctx, mFillColor);
 CGContextFillRect(ctx, shapeBounds);
 
 const float mStrokeColor[4] = {0.0,  0.0,  0.0,  1.0};
 CGContextSetStrokeColor( ctx, mStrokeColor);
 CGContextStrokeRect(ctx, shapeBounds);
 
 CGContextRestoreGState(ctx);
 }*/

CGContextRef CreateOffscreenBitmap(int width, int height) {
	unsigned rowBytes = 4 * width;
    void *imageBuffer = calloc(rowBytes * height, 1);
	
	CGColorSpaceRef genericColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    //CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGContextRef bmCtx = CGBitmapContextCreate(imageBuffer, width, height, 8, rowBytes, genericColorSpace, kCGImageAlphaLast);
	
	//CGContextSetFillColorSpace(bmCtx, genericColorSpace); 
	//CGContextSetStrokeColorSpace(bmCtx, genericColorSpace); 
	//CGColorSpaceRelease(genericColorSpace);
	return bmCtx;
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    if(argc != 6) {
        NSLog(@"usage: %s -i foreground.png background-strip.png -o output.png", argv[0]);
    } else if(strcmp(argv[1], "-i") == 0 && strcmp(argv[4],"-o") == 0) {
        FILE *foreground = fopen(argv[2], "r");
        FILE *background = fopen(argv[3], "r");

        if(foreground == 0 || background == 0) {
            printf("Could not open files\n");
            //exit(1);
        }
        
        fclose(foreground);
        fclose(background);
        
        
        NSImage *fgImage = [[NSImage alloc] initByReferencingFile:[NSString stringWithUTF8String:argv[2]]];
        NSImage *bgImage = [[NSImage alloc] initByReferencingFile:[NSString stringWithUTF8String:argv[3]]];
        
        //NSImage *oImage = [[[fgImage class] alloc] initWithSize:[fgImage size]];
        
        if(fgImage.size.height != bgImage.size.height) {
            NSLog(@"size mismatch");
            //exit(1);
        }
        
        //NSBitmapImageRep *fgBMP = [[fgImage representations] objectAtIndex:0];
        RGBPixel *fgPixels = (RGBPixel*)[[[fgImage representations] objectAtIndex:0] bitmapData];
        RGBPixel *bgPixels = (RGBPixel*)[[[bgImage representations] objectAtIndex:0] bitmapData];

        int row, column,
        widthInPixels = (int)fgImage.size.width, 
        heightInPixels = (int)fgImage.size.height;
        
        /*CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        CGLayerRef cLayer = CGLayerCreateWithContext(context, fgImage.size, NULL);
        CGContextRef cContext = CGLayerGetContext(cLayer);*/
        CGContextRef cContext = CreateOffscreenBitmap(widthInPixels, heightInPixels);
        
        for (row = 0; row < heightInPixels; row++) {
            RGBPixel *origPixel = &(bgPixels[row]);
            for (column = 0; column < widthInPixels; column++) {
                RGBPixel *resultPixel = &(fgPixels[((widthInPixels * row) + column)]);
                //NSLog(@"point: %i,%i  colors: RGB %i %i %i  %f  RGB %i %i %i  %f", row, column, resultPixel->redByte ,resultPixel->greenByte,resultPixel->blueByte, resultPixel->alphaByte, origPixel->redByte, origPixel->greenByte, origPixel->blueByte, origPixel->alphaByte);
                double oR = (resultPixel->redByte - origPixel->redByte)/(255.0 - origPixel->redByte);
                if(oR < 0) oR = oR + 1.0;
                //NSLog(@"point: %i,%i  opacity: %f", row, column, oR);
                //resultPixel->redByte = resultPixel->greenByte = resultPixel->blueByte = 255;
                //resultPixel->alphaByte = oR;
                /*CGContextSaveGState(cContext);
                CGContextSetRGBFillColor(cContext, 1.0, 1.0, 1.0, oR);// 13
                CGContextFillRect(cContext, CGRectMake(row, column, row+1, column+1));
                CGContextRestoreGState(cContext);*/
                //NSLog(@"point: %i,%i  colors: RGB %i %i %i", row, column, resultPixel->redByte ,resultPixel->greenByte,resultPixel->blueByte);
                
            }
        }
        
        CGImageRef image = CGBitmapContextCreateImage(cContext);
        ExportImage(image, argv[5]);
        
        //[oImage addRepresentation:fgBMP];
        
        //[[fgBMP representationUsingType:NSBMPFileType properties:nil] writeToFile:[NSString stringWithUTF8String:argv[5]] atomically:YES];
    }
    [pool drain];
    return 0;
}

void myDrawFlag(CGContextRef context, CGRect* contextRect) {
    int          i, j,
    num_six_star_rows = 5,
    num_five_star_rows = 4;
    float        start_x = 5.0,// 1
    start_y = 108.0,// 2
    red_stripe_spacing = 34.0,// 3
    h_spacing = 26.0,// 4
    v_spacing = 22.0;// 5
    CGContextRef myLayerContext1,
    myLayerContext2;
    CGLayerRef   stripeLayer,
    starLayer;
    CGRect       myBoundingBox,// 6
    stripeRect,
    starField;
    // ***** Setting up the primitives *****
    const CGPoint myStarPoints[] = {{ 5, 5},   {10, 15},// 7
        {10, 15},  {15, 5},
        {15, 5},   {2.5, 11},
        {2.5, 11}, {16.5, 11},
        {16.5, 11},{5, 5}};
    
    stripeRect  = CGRectMake (0, 0, 400, 17); // stripe// 8
    starField  =  CGRectMake (0, 102, 160, 119); // star field// 9
    
    myBoundingBox = CGRectMake (0, 0, contextRect->size.width, // 10
                                contextRect->size.height);
    
    // ***** Creating layers and drawing to them *****
    stripeLayer = CGLayerCreateWithContext (context, // 11
                                            stripeRect.size, NULL);
    myLayerContext1 = CGLayerGetContext (stripeLayer);// 12
    
    CGContextSetRGBFillColor (myLayerContext1, 1, 0 , 0, 1);// 13
    CGContextFillRect (myLayerContext1, stripeRect);// 14
    
    starLayer = CGLayerCreateWithContext (context,
                                          starField.size, NULL);// 15
    myLayerContext2 = CGLayerGetContext (starLayer);// 16
    CGContextSetRGBFillColor (myLayerContext2, 1.0, 1.0, 1.0, 1);// 17
    CGContextAddLines (myLayerContext2, myStarPoints, 10);// 18
    CGContextFillPath (myLayerContext2);    // 19
    
    // ***** Drawing to the window graphics context *****
    CGContextSaveGState(context);    // 20
    for (i=0; i< 7;  i++)   // 21
    {
        CGContextDrawLayerAtPoint (context, CGPointZero, stripeLayer);// 22
        CGContextTranslateCTM (context, 0.0, red_stripe_spacing);// 23
    }
    CGContextRestoreGState(context);// 24
    
    CGContextSetRGBFillColor (context, 0, 0, 0.329, 1.0);// 25
    CGContextFillRect (context, starField);// 26
    
    CGContextSaveGState (context);              // 27
    CGContextTranslateCTM (context, start_x, start_y);      // 28
    for (j=0; j< num_six_star_rows;  j++)   // 29
    {
        for (i=0; i< 6;  i++)
        {
            CGContextDrawLayerAtPoint (context,CGPointZero,
                                       starLayer);// 30
            CGContextTranslateCTM (context, h_spacing, 0);// 31
        }
        CGContextTranslateCTM (context, (-i*h_spacing), v_spacing); // 32
    }
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, start_x + h_spacing/2, // 33
                           start_y + v_spacing/2);
    for (j=0; j< num_five_star_rows;  j++)  // 34
    {
        for (i=0; i< 5;  i++)
        {
            CGContextDrawLayerAtPoint (context, CGPointZero,
                                       starLayer);// 35
            CGContextTranslateCTM (context, h_spacing, 0);// 36
        }
        CGContextTranslateCTM (context, (-i*h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGLayerRelease(stripeLayer);// 37
    CGLayerRelease(starLayer);        // 38
}



