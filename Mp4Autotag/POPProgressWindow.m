//
//  POPProgressWindow.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPProgressWindow.h"

@implementation POPProgressWindow
{
	NSModalSession session;
	bool as_sheet;
}
@synthesize progressBar;
@synthesize messageTextField;
-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	NSLog(@"Created POPProgressWindow...");
	session = nil;
	as_sheet = false;
	return [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
}
-(void)awakeFromNib
{
	
}
-(void) hide {
	[[self progressBar] setDoubleValue:0];
	if(as_sheet)
	{
		[[NSApplication sharedApplication] endSheet:self returnCode:0];
	}
	if(session != nil)
	{
		[NSApp endModalSession:session];
		
	}
	[self close];
	session = nil;
}

-(void) show:(NSString*)msg 
	progress:(double)percent 
{
	[[self progressBar] setDoubleValue:percent];
	[[self messageTextField] setStringValue:msg];
	if(session == nil && !as_sheet)
	{
		session = [NSApp beginModalSessionForWindow:self];
	}
	else {
		[[self messageTextField] display];
	}
}

-(void) showSheet:(NSString*)msg 
		 progress:(double)percent
		   parent:(NSWindow*)parent
{
	as_sheet = true;
	[[NSApplication sharedApplication] beginSheet:self 
								   modalForWindow:parent
									modalDelegate:self
								   didEndSelector:nil
									  contextInfo:(void*)self];
	[self show:msg progress:percent];
}
@end
