//
//  POPAutomatedAutotagWindow.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPAutomatedAutotagWindow.h"
#import "POPAutomatedAutotagQueueView.h"
#import "POPMp4FileTag.h"
#import "POPMp4FileTagSearch.h"
#import "fixmoov.h"

@implementation POPAutomatedAutotagWindow
{
	//members
	POPAutomatedAutotagQueueView* queueViewer;
};

//properties
@synthesize queueView;
@synthesize progressWindow;
@synthesize propertyView;
@synthesize vsplit;

//subclassing
-(id)initWithContentRect:(NSRect)contentRect 
			   styleMask:(NSUInteger)windowStyle 
				 backing:(NSBackingStoreType)bufferingType 
				   defer:(BOOL)deferCreation 
{
	NSLog(@"Created POPAutomatedAutotagWindow...");
	
	return [super initWithContentRect:contentRect 
							styleMask:windowStyle 
							  backing:bufferingType 
								defer:deferCreation];
}

-(void)awakeFromNib
{
	NSLog(@"awakeFromNib POPAutomatedAutotagWindow...");
	queueViewer = [[POPAutomatedAutotagQueueView alloc] init];
	[queueViewer setPropertyView:[self propertyView]];
	[queueView setDataSource:(id<NSTableViewDataSource>)queueViewer];
	[queueView setDelegate:(id<NSTableViewDelegate>)queueViewer];
	return;
}
//actions
- (IBAction)closeClick:(id)sender {
	NSLog(@"closing POPAutomatedAutotagWindow...");
	//save out the changes
	for(int i = 0; i < [[queueViewer queue] count]; i++)
	{
		NSArray* tags = [[queueViewer queue] objectAtIndex:i];
		POPMp4FileTag* otag = [tags objectAtIndex:0];
		POPMp4FileTag* ntag = nil;
		if([tags count] == 2) ntag = [tags objectAtIndex:1];
		[otag mergeData:ntag];
	}
	
	[[NSApplication sharedApplication] endSheet:self returnCode:0];
	[self close];
	return;
}

- (IBAction)undoClick:(id)sender {
	if([[self queueView] selectedRow] >= 0)
	{
		NSArray* tags = [[queueViewer queue] objectAtIndex:[[self queueView] selectedRow]];
		POPMp4FileTag* otag = [tags objectAtIndex:0];
		POPMp4FileTag* ntag = nil;
		if([tags count] == 2) ntag = [tags objectAtIndex:1];
		NSString* msg = [NSString stringWithFormat:@"Undo: %@", [otag filename]];
		[[self progressWindow] show:msg progress:33];
		if([[[NSUserDefaults standardUserDefaults] valueForKey:@"renameFile"] intValue]) {
			msg = [NSString stringWithFormat:@"Renaming to: %@", [otag filename]];
			[[self progressWindow] show:msg progress:66];
			[ntag renameTo:[otag filename]];
		}
		[otag save];
		NSMutableArray* ma = [NSMutableArray arrayWithArray:[queueViewer queue]];
		[ma removeObject:tags];
		[queueViewer setQueue:ma];
		[queueViewer refresh];
	}
}
//functions
- (void)clearResults{
	[queueViewer setQueue:[NSArray array]];
	[[self queueView] reloadData];
}
- (bool)autotagQueue:(NSArray *)q {
	int i = 0;
	NSMutableArray* results = [[NSMutableArray alloc] init];
	[queueViewer setQueue:results];
	[[self progressWindow] showSheet:@"Building queue..." progress:0 parent:self];
	[[self progressWindow] show:@"Searching queue..." progress:1];
	POPMp4FileTagSearch* mp4SearchFileTagTable = [[POPMp4FileTagSearch alloc] init];
	for (i = 0; i < [q count]; i++) {
		POPMp4FileTag* otag = [q objectAtIndex:i];
		POPMp4FileTag* ntag = [[POPMp4FileTag alloc] init];
		[ntag mergeData:otag];
		
		NSString* msg = [NSString stringWithFormat:@"Searching for %@", [otag filename]];
		float f = (float)i/(float)[q count];
		double prog = f*100;
		[[self progressWindow] show:msg progress:prog];
		[mp4SearchFileTagTable searchWithFileTag:otag];
		POPMp4FileTag* stag = [mp4SearchFileTagTable chooseResult:0];
		if(stag != nil){
			msg = [NSString stringWithFormat:@"Merge and save: %@", [ntag filename]];
			f = ((float)i + 0.33)/(float)[q count];
			prog = f*100;
			[[self progressWindow] show:msg progress:prog];
			[ntag mergeData:stag];
			[ntag save];
			if([[[NSUserDefaults standardUserDefaults] valueForKey:@"fixForNetwork"] intValue]) {
				msg = [NSString stringWithFormat:@"Fixing MOOV on: %@", [ntag filename]];
				f = ((float)i + 0.66)/(float)[q count];
				prog = f*100;
				[[self progressWindow] show:msg progress:prog];
				fixMOOV((char*)[[ntag filename] cStringUsingEncoding:NSASCIIStringEncoding]);
			}
			if([[[NSUserDefaults standardUserDefaults] valueForKey:@"renameFile"] intValue]) {
				msg = [NSString stringWithFormat:@"Renaming: %@", [ntag filename]];
				f = ((float)i + 0.66)/(float)[q count];
				prog = f*100;
				[[self progressWindow] show:msg progress:prog];
				[ntag rename];
			}
		}
		else {
			[ntag setProperty:@"Name" value:@"Not Found"];
		}
		NSArray *tags = [NSArray arrayWithObjects:otag, ntag, nil];
		[results addObject:tags];
		[[self queueView] reloadData];
	}
	mp4SearchFileTagTable = nil;
	[[self progressWindow] show:@"Done..." progress:100];
	[[self queueView] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	[[self progressWindow] hide];
	return true;
}
@end
