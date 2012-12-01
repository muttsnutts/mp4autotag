//
//  POPAutomatedAutotagQueueView.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPAutomatedAutotagQueueView.h"
#import "POPMp4FileTag.h"

@implementation POPAutomatedAutotagQueueView
{
	NSTableView* _propertyView;
	NSTableView* _tv;
}
@synthesize queue = _queue;
@synthesize propertyViewer = _propertyViewer;

- (id)init
{
	POPAutomatedAutotagQueueView* rtn = [super init];
	[rtn setPropertyViewer:[[POPAutomatedAutotagPropertyView alloc] init]];
	[rtn setQueue:[NSArray array]];
	[rtn setPropertyView:nil];
	return rtn;
}

- (void) setPropertyView:(NSTableView *)propertyView
{
	_propertyView = propertyView;
	[_propertyView setDataSource:(id<NSTableViewDataSource>)_propertyViewer];
}

- (NSTableView*) propertyView
{
	return _propertyView;
}

- (void) refresh
{
	[_tv reloadData];
	[self refreshProperies:_tv];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	_tv = aTableView;
	return [_queue count];
}

- (id)tableView:(NSTableView*)aTableView 
objectValueForTableColumn:(NSTableColumn*)aTableColumn 
			row:(NSInteger)rowIndex
{
	NSString* colident = [aTableColumn identifier];
	NSArray* tags = [_queue objectAtIndex:rowIndex];
	POPMp4FileTag* otag = [tags objectAtIndex:0];
	POPMp4FileTag* ntag = nil;
	if([tags count] == 2) ntag = [tags objectAtIndex:1];
	if([colident compare:@"OriginalImage"] == 0){
		NSImage* img = [otag image];
		return img;
	}
	else if([colident compare:@"OriginalName"] == 0){
		return [[otag filename] lastPathComponent];
	}
	else if([colident compare:@"NewImage"] == 0){
		if(ntag != nil) return [ntag image];
		return nil;
	}
	else if([colident compare:@"NewName"] == 0){
		NSTextFieldCell *cell = [aTableColumn dataCellForRow:rowIndex];
		if(ntag != nil) 
		{
			if([[ntag property:@"Name"] compare:@"Not Found"] == 0)
			{
				[cell setDrawsBackground:YES];
				[cell setBackgroundColor:[NSColor redColor]];
			}
			else {
				[cell setDrawsBackground:NO];
			}
			return [[ntag filename] lastPathComponent];
		}
		[cell setDrawsBackground:NO];
		return nil;
	}
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self refreshProperies:[aNotification object]];
}

-(void) refreshProperies:(NSTableView*)tv {
	if(_propertyView != nil)
	{
		if([tv selectedRow] >= 0)
		{
			NSArray* tags = [_queue objectAtIndex:[tv selectedRow]];
			[_propertyViewer setProperties:tags];
			[_propertyView setDataSource:(id<NSTableViewDataSource>)_propertyViewer];
		}
		else {
			[_propertyView setDataSource:nil];
		}
		[_propertyView reloadData];
	}
}
@end
