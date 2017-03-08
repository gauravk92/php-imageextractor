#import <Cocoa/Cocoa.h>

@interface NSImage (CGImageConversions)

- (NSBitmapImageRep *)bitmap;
- (CGImageRef)cgImage;

@end