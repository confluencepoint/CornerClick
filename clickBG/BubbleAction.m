//
//  BubbleAction.m
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BubbleAction.h"

static NSImage *triImage;
@interface BubbleAction (InternalMethods)
- (void)drawAction:(NSString*)label withIcon:(NSImage*)icon atPoint:(NSPoint)inside;
- (void) calcPreferredSize;
@end

@implementation BubbleAction

- (id) initWithStringAttributes: (NSDictionary *) attrs
            smallTextAttributes: (NSDictionary *) sattrs
					 andSpacing:(float) space

{
    return [self initWithStringAttributes:attrs 
                      smallTextAttributes:  sattrs
                               andSpacing:space
								   andActions:nil];
}
- (id) initWithStringAttributes: (NSDictionary *) attrs
            smallTextAttributes: (NSDictionary *) sattrs
					 andSpacing:(float) space
					 andActions:(NSArray *) theActions
{
    if(self=[super init]){
		spacingSize=space;
		stringAttrs = [[NSDictionary alloc] initWithDictionary:attrs];
        smallTextAttrs = [[NSDictionary alloc] initWithDictionary:sattrs];
		if(theActions != nil){
			actions = [[NSArray alloc] initWithArray:theActions];
			[self calcPreferredSize];
		}
	}
	return self;
}

- (void) dealloc
{
	[stringAttrs release];
    [smallTextAttrs release];
	[actions release];
}



- (NSString *)modifiersLabel
{
    ClickAction *act = [actions objectAtIndex:0];
    return [CornerClickSupport labelForModifiers:[act modifiers]
                                      andTrigger:[act trigger]
                                     localBundle:[NSBundle bundleForClass:[self class]]];
}

- (void) setActions:(NSArray *)theActions
{
	NSArray *arr = [[NSArray alloc] initWithArray: theActions];
	[actions release];
	actions=arr;
}
- (NSArray *)actions
{
	return [[actions retain] autorelease];
}

- (void) setSpacingSize: (float) size
{
	spacingSize=size;
	[self calcPreferredSize];
}
- (NSSize) preferredSize
{
	return preferredSize;
}
- (void) calcPreferredSize
{
	int i;
	float x,y;
	float mwidth,mheight;
	NSSize temp;
	NSSize textSize=NSMakeSize(0,0);
	mwidth=0;
	mheight=0;
	if(actions != nil){
			
		for(i=0;i<[actions count];i++){
			x=0;
			y=0;
			ClickAction* act = (ClickAction*)[actions objectAtIndex:i];
			if([act label]!=nil){
				temp = [[act label] sizeWithAttributes:stringAttrs];
				x = temp.width/2;
				y = temp.height/2;
			}
			if([act icon]!=nil){
				
				x+=36;
				if(y<32)
					y=32;
			}
			if(i>0){
				y+=spacingSize;
				x+=16;
			}
			if(x>mwidth){
				mwidth=x;
			}
			mheight+=y;
				
		}
	}
	textSize.width=ceil(mwidth);
	textSize.height=ceil(mheight);
	preferredSize= textSize;
}

- (void) drawInRect: (NSRect) rect
{
	float tF;
	int i,ox;
	float curHeight=rect.size.height;
	
	for(i=0;i<[actions count];i++){
		ClickAction *act = (ClickAction *)[actions objectAtIndex:i];
		tF=0;
		ox=0;
		if([act label]!=nil){
			NSSize temp = [[act label] sizeWithAttributes:stringAttrs];
			tF = temp.height/2;
			
		}
		if([act icon] !=nil && tF<32){
			tF=32;
		}
		curHeight = curHeight-tF;
		if(i>0){
			curHeight-=spacingSize;
			ox=16;
            int wide=10;
            int high=10;
            //draw a triangle or something
            [[BubbleAction triangleImage] compositeToPoint:NSMakePoint(rect.origin.x+ox/2-wide/2, rect.origin.y+curHeight+tF/2-high/2) 
                                                 operation: NSCompositeSourceOver];
		}
		NSPoint inside = NSMakePoint(floor(rect.origin.x+ox), floor(curHeight + rect.origin.y)); 
		[self drawAction:[act label] withIcon:[act icon] atPoint:inside];
		
		
	}
	
}

+ (void) initialize
{
    int wide=10;
    int high=10;
    
    if(triImage == nil){
        triImage = [[NSImage alloc] initWithSize:NSMakeSize(wide,high)];
        [triImage lockFocus];
        NSRect rect = {0,0,wide,high};
        NSBezierPath *nbp = [[[NSBezierPath alloc] init] autorelease];
        [nbp moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
        [nbp lineToPoint:NSMakePoint(rect.origin.x+wide, rect.origin.y+high/2)];
        [nbp lineToPoint:NSMakePoint(rect.origin.x, rect.origin.y+high)];
        [nbp closePath];
        [BubbleView addShadow:nbp depth:1.5];
        [triImage unlockFocus];
    }
}
+ (NSImage *) triangleImage
{
    return [[triImage retain] autorelease];
}


- (void)drawAction:(NSString*)label withIcon:(NSImage*)icon atPoint:(NSPoint)inside
{
	BOOL aa;
    NSImage *tempImg;
    NSSize tSize;
    //NSRect rect = [self frame];
	
	
	float xoff=0;
	float yoff=0;
	
	if(label == nil){
		tSize=NSMakeSize(0,0);
	}else{
		tSize=[label sizeWithAttributes: stringAttrs];
	}
	//draw an icon if it's set
	if(icon!=nil){
		xoff+=36;
		yoff+=(32 - (tSize.height/2))/2;
		[icon drawInRect:NSMakeRect(inside.x, inside.y, 32, 32) 
				fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
			   operation:NSCompositeSourceOver
				fraction:1.0];
		//[icon compositeToPoint: inside operation:NSCompositeSourceOver];
	}
	
	if(label!=nil){
		//create a new image, draw double size text, composite at half size on top of bubble
		
		tempImg = [[NSImage alloc] initWithSize:tSize];
		[tempImg lockFocus];
		
		[[NSColor clearColor] set];
		NSRectFill(NSMakeRect(0,0,tSize.width,tSize.height));
		aa = [[NSGraphicsContext currentContext] shouldAntialias];
		[[NSGraphicsContext currentContext] setShouldAntialias: YES];
		
		
		[label drawAtPoint:NSZeroPoint withAttributes: stringAttrs ];
		
		[tempImg unlockFocus];
		
		[[NSGraphicsContext currentContext] setShouldAntialias: aa];
		
		//NSImageRep *brep = [tempImg bestRepresentationForDevice:nil];
		
		[tempImg  drawInRect:NSMakeRect(inside.x+xoff, inside.y+yoff, tSize.width/2,tSize.height/2)
					fromRect:NSMakeRect(0, 0, tSize.width, tSize.height)
				   operation:NSCompositeSourceOver
					fraction:1.0];
		[tempImg release];
	}
	
	
}

- (NSComparisonResult)triggerCompare:(BubbleAction *)anAction
{
    ClickAction *selfAct = (ClickAction *)[[self actions] objectAtIndex:0];
    ClickAction *anAct = (ClickAction *)[[anAction actions] objectAtIndex:0];
    return [selfAct triggerCompare:anAct];
}


@end
