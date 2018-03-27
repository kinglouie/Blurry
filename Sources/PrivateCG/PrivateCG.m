
#import "include/PrivateCG.h"

#import <Cocoa/Cocoa.h>
 #import <Foundation/Foundation.h>

/* XXX: Undocumented private typedefs for CGSSpace */
typedef NSUInteger CGSConnectionID;
typedef NSUInteger CGSSpaceID;
typedef enum CGSSpaceSelector
{
    kCGSSpaceCurrent = 5,
    kCGSSpaceOther = 6,
    kCGSSpaceAll = 7
} CGSSpaceSelector;

@implementation PrivateCG

    static NSString * const CGSScreenIDKey = @"Display Identifier";
    static NSString * const CGSSpaceIDKey = @"ManagedSpaceID";
    static NSString * const CGSSpacesKey = @"Spaces";
    static NSString * const NSScreenNumberKey = @"NSScreenNumber";

    // XXX: Undocumented private API functions

    // Get the CGSConnectionID for the default connection for this process
    extern CGSConnectionID CGSMainConnectionID(void);
    // Get the CGSSpaceIDs for all spaces in order
    extern CFArrayRef CGSCopyManagedDisplaySpaces(CGSConnectionID connection);
    // Add the given windows (CGWindowIDs) to the given spaces (CGSSpaceIDs)
    extern void CGSAddWindowsToSpaces(CGSConnectionID connection, CFArrayRef windowIds, CFArrayRef spaceIds);
    // Move the given windows (CGWindowIDs) to the given space (CGSSpaceID)
    extern void CGSMoveWindowsToManagedSpace(CGSConnectionID connection, CFArrayRef windowIds, CGSSpaceID SpaceId);
    // Get the CGSSpaceIDs for the given WindowRef
    extern CFArrayRef CGSCopySpacesForWindows(CGSConnectionID Connection, CGSSpaceSelector Type, CFArrayRef Windows);

    + (NSArray<NSNumber *> *) getAllSpaces
    {
        NSMutableArray *spaces = [NSMutableArray array];

        NSArray *displaySpacesInfo = CFBridgingRelease(CGSCopyManagedDisplaySpaces(CGSMainConnectionID()));
        for (NSDictionary<NSString *, id> *spacesInfo in displaySpacesInfo) {
            NSArray<NSNumber *> *identifiers = [spacesInfo[CGSSpacesKey] valueForKey:CGSSpaceIDKey];
            for (NSNumber *identifier in identifiers) {
                [spaces addObject:identifier];
            }
        }
        return spaces;
    }

    + (NSArray<NSNumber *> *) getSpacesforScreen:(NSScreen*)scr
    {
        NSMutableArray *spaces = [NSMutableArray array];

        id uuid = CFBridgingRelease(CGDisplayCreateUUIDFromDisplayID([scr.deviceDescription[NSScreenNumberKey] unsignedIntValue]));
        if(uuid) {
            NSString *DisplayID = CFBridgingRelease(CFUUIDCreateString(NULL, (__bridge CFUUIDRef) uuid));

            NSArray *displaySpacesInfo = CFBridgingRelease(CGSCopyManagedDisplaySpaces(CGSMainConnectionID()));
            for (NSDictionary<NSString *, id> *spacesInfo in displaySpacesInfo) {
                NSString *DisplayIdentifier = spacesInfo[@"Display Identifier"];
                if([DisplayIdentifier isEqualToString:DisplayID]) {
                    NSArray<NSNumber *> *identifiers = [spacesInfo[CGSSpacesKey] valueForKey:CGSSpaceIDKey];
                    for (NSNumber *identifier in identifiers) {
                        [spaces addObject:identifier];
                    }
                }
            }
        }
        return spaces;
    }

    + (NSNumber *) getSpaceForWindow:(uint32_t)window
    {
        NSArray *NSArrayWindow = @[ @(window) ];
        CFArrayRef Spaces = CGSCopySpacesForWindows(CGSMainConnectionID(), kCGSSpaceAll, (__bridge CFArrayRef) NSArrayWindow);
        int NumberOfSpaces = (int)CFArrayGetCount(Spaces);

        if(NumberOfSpaces == 1) {
            NSNumber *Id = (__bridge NSNumber *) CFArrayGetValueAtIndex(Spaces, 0);
            CGSSpaceID SpaceId = [Id intValue];
            return [NSNumber numberWithUnsignedLong: SpaceId];
        } else
            return [NSNumber numberWithInt: 0];
    }

    + (void) moveWindow:(NSNumber*)window toSpace:(NSNumber*)space
    {
        CGSMoveWindowsToManagedSpace(CGSMainConnectionID(),
             (__bridge CFArrayRef) @[ @(window.unsignedIntValue) ],
             space.unsignedIntValue
        );
    }

@end
