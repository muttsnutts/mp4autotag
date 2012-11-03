//
//  POPMp4FileTagTable.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPMp4FileTagTable.h"

@implementation POPMp4FileTagTable
{
	NSTableView* _tableView;
	NSTextField* _currentFilenameLabel;
	POPAppDelegate* _parent;
}

@synthesize mp4tags = _mp4tags;
@synthesize propertyView = _propertyView;
@synthesize propertyImageView = _propertyImageView;
@synthesize loadWnd = _loadWnd;

-(id) initWithParent:(POPAppDelegate*)parent 
{	
	_mp4tags = [NSMutableArray array];
	_propertyView = [parent mp4FileTagView];
	_propertyImageView = [parent mp4FileTagImage];
	_loadWnd = [parent loadWnd];
	_tableView = [parent mp4FileTagTableView];
	_currentFilenameLabel = [parent currentFilenameLabel];
	_parent = parent;
	return [super init];
}

-(void) addMp4FileTag:(POPMp4FileTag*) tag at:(int)idx {	
	[_loadWnd show:[NSString stringWithFormat:@"adding file: %@", [tag filename]]];
	if(idx == -1)
	{
		[_mp4tags addObject:tag];
	}
	else {
		[_mp4tags insertObject:tag atIndex:idx];
	}
	[self reloadAll];
	[_loadWnd hide];
}

-(void) addMp4FileWalk:(NSArray*)urls atIndex:(unsigned int)atIdx
{
	for(int i = 0; i < [urls count]; i++)
	{
		NSURL* url = [urls objectAtIndex:i];
		NSString* fn = [url path];
		
		NSLog(@"Try adding: %@", fn);
		
		BOOL isdir;
		if([[NSFileManager defaultManager] fileExistsAtPath:fn isDirectory:&isdir])
		{
			if(isdir)
			{
				[[self loadWnd] show:[NSString stringWithFormat:@"Change directory to %@", fn]];
				NSError* e;
				[self addMp4FileWalk:[[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
																   includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey, nil]
																				      options:NSDirectoryEnumerationSkipsHiddenFiles
																					    error:&e] 
							 atIndex:atIdx];
				[[self loadWnd] hide];
			}
			else {
				NSString* ext = [fn pathExtension];
				if([ext length] > 3)
				{
					ext = [ext substringToIndex:3];
				}
				if([ext compare:@"mp4" options:NSCaseInsensitiveSearch] == 0 ||
			       [ext compare:@"m4v" options:NSCaseInsensitiveSearch] == 0)
				{
					NSLog(@"Gonna open file: %@", fn);
					[[self loadWnd] show:[NSString stringWithFormat:@"Adding file: %@", [fn lastPathComponent]]];
					POPMp4FileTag* tag = nil;
					@try {
						tag = [[POPMp4FileTag alloc] initWithFile:fn];
					}
					@catch (NSException *exception) {
						NSRunAlertPanel(@"mp4tags", 
										@"mp4tags returned:\n%@\n\n This is usually due to the encoding, use ffmpeg to clean the file.",
										@"OK", nil, nil, [exception reason]);
					}
					if(tag != nil)
					{
						[self addMp4FileTag:tag at:atIdx];
						tag = nil;
					}
					[[self loadWnd] hide];
				}
			}
		}
	}
}

-(void) addMp4Files:(NSArray*) urls atIndex:(unsigned int)atIdx
{
	[_loadWnd show:@"Adding files..."];
	[self addMp4FileWalk:urls atIndex:atIdx];
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:atIdx];
	[_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
	[self reloadAll];
	[_loadWnd hide];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_mp4tags count];
}

- (id)tableView:(NSTableView*)aTableView 
objectValueForTableColumn:(NSTableColumn*)aTableColumn 
			row:(NSInteger)rowIndex
{
	NSString* colheadstr = [[aTableColumn headerCell] stringValue];
	POPMp4FileTag* tag = [_mp4tags objectAtIndex:rowIndex];
	if([colheadstr compare:@"Image"] == 0){
		NSImage* img = [tag image];
		return img;
	}
	else if([colheadstr compare:@"Filename"] == 0){
		return [tag filename];
	}
	else {
		return [[[tag properties] objectForKey:colheadstr] objectForKey:@"value"];
	}
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self refreshProperies];
}

- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id < NSDraggingInfo >)info 
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSLog(@"validateDrop:%d operation:%d",(int)[info draggingSourceOperationMask], (int)operation);
	if(operation == NSDragOperationCopy)
	{
		return operation;
	}
	
	return NSDragOperationNone;
}

- (void)tableView:(NSTableView *)tableView 
  draggingSession:(NSDraggingSession *)session 
	 endedAtPoint:(NSPoint)screenPoint 
		operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationNone) {
		NSPasteboard *pboard = [session draggingPasteboard];
		NSArray *classArray = [NSArray arrayWithObject:[NSURL class]]; 
		NSArray *urls = [pboard readObjectsForClasses:classArray options:nil];
		
		for(int i = 0; i < [_mp4tags count]; i++)
		{
			POPMp4FileTag* tag = [_mp4tags objectAtIndex:i];
			if([[tag filename] compare:[[urls objectAtIndex:0] path]] == 0)
			{
				[_mp4tags removeObject:tag];
				[self reloadAll];
				break;
			}
		}
	}
}

-(void) reloadAll {
	[_tableView reloadData];
	[self refreshProperies];
}

-(void) refreshProperies {
	if(_propertyView != nil)
	{
		if([_tableView selectedRow] >= 0)
		{
			POPMp4FileTag* tag = [_mp4tags objectAtIndex:[_tableView selectedRow]];
			[_propertyView setDataSource:(id<NSTableViewDataSource>)tag];
			[_currentFilenameLabel setStringValue:[tag filename]];
			NSImage* img = [tag image];
			if(_propertyImageView != nil)
				[_propertyImageView setImage: img];
		}
		else {
			[_propertyView setDataSource:nil];
			[_propertyImageView setImage:nil];
			[_currentFilenameLabel setStringValue:@""];
		}
		[_propertyView reloadData];
	}
	if(_parent != nil) [_parent refreshButtons];
}

- (void)removeMp4FileTagAt:(int)idx {
	[_mp4tags removeObjectAtIndex:idx];
	[self reloadAll];
}

-(void) saveMp4FileTagAt:(int)idx {
	[_loadWnd show:[NSString stringWithFormat:@"Saving file %@", [[_mp4tags objectAtIndex:idx] filename]]];
	if(![[_mp4tags objectAtIndex:idx] save])
		NSRunAlertPanel(@"mp4tags", 
						@"Unable to save file: %@\n\n This is usually due:\n1. The file moved since it was loaded in Mp4Autotag\n2. The encoding is not a proper mp4, use ffmpeg to clean the file.",
						@"OK", nil, nil, [[_mp4tags objectAtIndex:idx] filename]);
	[self reloadAll];
	[_loadWnd hide];
}

-(void) saveAllMp4FileTags {
	[_loadWnd show:@"Saving all files..."];
	for(int i = 0; i < [_mp4tags count]; i++) {
		[self saveMp4FileTagAt:i];
	}
	[_loadWnd hide];
}

- (BOOL)tableView:(NSTableView *)aTableView 
	   acceptDrop:(id < NSDraggingInfo >)info 
			  row:(NSInteger)row 
	dropOperation:(NSTableViewDropOperation)operation
{
	NSLog(@"acceptDrop:%d operation:%d",(int)[info draggingSourceOperationMask], (int)operation);
	NSPasteboard *pboard = [info draggingPasteboard];
	if(operation == NSDragOperationCopy)
	{
		if([[pboard types] containsObject:NSFilenamesPboardType]) 
		{
			NSArray *classArray = [NSArray arrayWithObject:[NSURL class]]; 
			NSArray *urls = [pboard readObjectsForClasses:classArray options:nil];
			
			if(aTableView == [info draggingSource])
			{
				for(int i = 0; i < [_mp4tags count]; i++)
				{
					POPMp4FileTag* tag = [_mp4tags objectAtIndex:i];
					if([[tag filename] compare:[[urls objectAtIndex:0] path]] == 0)
					{
						if(i < row) row--;
						[_mp4tags removeObject:tag];
						[_mp4tags insertObject:tag atIndex:row];
						[self reloadAll];
						return YES;
					}
				}
				return NO;
			}
			else {
				[NSApp activateIgnoringOtherApps:YES];
				[self addMp4Files:urls atIndex:row];
				return YES;
			}
		}
	}
	return NO;
}

- (BOOL) tableView: (NSTableView *) view 
		 writeRows: (NSArray *) rows 
	  toPasteboard: (NSPasteboard *) pboard
{
	int idx = [[rows objectAtIndex:0] intValue];
	if(idx >= 0)
	{
		NSArray *arrayOfURLs = [NSArray arrayWithObjects:[[NSURL alloc] initFileURLWithPath:[[_mp4tags objectAtIndex:idx] filename]], nil];
		[pboard clearContents];
		[pboard writeObjects:arrayOfURLs];
		return YES;
	}
	return NO;
}
@end
