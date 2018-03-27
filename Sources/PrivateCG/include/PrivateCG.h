
#import <Cocoa/Cocoa.h>

@interface PrivateCG : NSObject

    + (NSArray<NSNumber *> *) getAllSpaces;
    + (NSArray<NSNumber *> *) getSpacesforScreen:(NSScreen *)scr;
    + (NSNumber *) getSpaceForWindow:(uint32_t)window;
    + (void) moveWindow:(NSNumber*)window toSpace:(NSNumber*)space;

@end
