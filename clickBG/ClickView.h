/* ClickView */

#import <Cocoa/Cocoa.h>
#import "ClickAction.h"

@interface ClickView : NSView
{
    NSArray *myActions;
    NSImage *drawed;
    NSTrackingRectTag trackTag;
    BOOL selected;
    int corner;
}

- (id)initWithFrame:(NSRect)frameRect action:(ClickAction *)anAction corner:(int)theCorner;

- (id)initWithFrame:(NSRect)frameRect actions:(NSArray *)actions corner:(int) theCorner;

- (void) drawBuf: (NSRect) rect;
- (void) setSelected: (BOOL) selected;
//- (ClickAction *) clickAction;
//- (void) setClickAction: (ClickAction *) action;
- (NSArray *) clickActions;
- (void) setClickActions: (NSArray *) actions;
- (ClickAction *) clickActionForModifierFlags: (unsigned int)modifiers;
- (void) setTrackingRectTag:(NSTrackingRectTag) tag;
- (NSTrackingRectTag) trackingRectTag;
@end
