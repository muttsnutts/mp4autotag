//
//  POPLoadingWindow.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPLoadingWindow.h"

@implementation POPLoadingWindow 
{
	NSModalSession session;
	NSMutableArray* msgStack;	
}
@synthesize msgLabel;

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	NSLog(@"Created POPLoadingWindow...");
	
	session = nil;
	msgStack = [NSMutableArray arrayWithCapacity:1];
	
	return [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
}

-(void) addMsg:(NSString*)msg {
	[msgStack addObject:(id)msg];
	[[self msgLabel] setStringValue:msg];
}

-(void) hide {
	if([msgStack count] > 0) {
		[msgStack removeLastObject];
		if([msgStack count] > 0) {
			[[self msgLabel] setStringValue: [msgStack lastObject]];
		}
		else {
			[NSApp endModalSession:session];
			[self close];
			session = nil;
			[[self msgLabel] setStringValue:@""];
		}
	}
}

-(void) show:(NSString*)msg {
	[self addMsg:msg];
	if(session == nil)
	{
		session = [NSApp beginModalSessionForWindow:self];
	}
	
}

@end
