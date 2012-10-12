//
//  POPAppDelegate.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPAppDelegate.h"
#import "POPMp4FileTagSearch.h"

@implementation POPAppDelegate
{
	POPMp4FileTagTable* mp4FileTagTable;
	POPMp4FileTagSearch* mp4SearchFileTagTable;
	NSArray* attags;
	int attags_idx;
}

@synthesize window = _window;
@synthesize loadWnd = _loadWnd;
@synthesize mp4FileTagTableView = _mp4FileTagTableView;
@synthesize mp4FileTagView = _mp4FileTagView;
@synthesize currentFilenameLabel = _currentFilenameLabel;
@synthesize mp4FileTagImage = _mp4FileTagImage;
@synthesize searchResultWindow = _searchResultWindow;
@synthesize customSearchWindow = _customSearchWindow;
@synthesize searchTableView = _searchTableView;
@synthesize seachFilenameLabel = _seachFilenameLabel;
@synthesize customSearchWindowTabView = _custumeSearchWindowTabView;
@synthesize customSearchWindowSeriesTextField = _customSearchWindowSeriesTextField;
@synthesize customSearchWindowSeasonNumberTextField = _customSearchWindowSeasonNumberTextField;
@synthesize customSearchWindowEpisodeNumberTextField = _customSearchWindowEpisodeNumberTextField;
@synthesize customSearchWindowMovieTextField = _customSearchWindowMovieTextField;
@synthesize customSearchWindowUseSameSeriesCheckBox = _customSearchWindowUseSameSeriesCheckBox;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	mp4FileTagTable = [[POPMp4FileTagTable alloc] initWithViews:[self mp4FileTagTableView] 
														tagView:[self mp4FileTagView] 
													  imageView:[self mp4FileTagImage] 
										   currentFilenameLabel:[self currentFilenameLabel]
														loadWnd:[self loadWnd]];
	mp4SearchFileTagTable = nil;
	[[self mp4FileTagTableView] setDataSource:(id<NSTableViewDataSource>)mp4FileTagTable];
	[[self mp4FileTagTableView] setDelegate:(id<NSTableViewDelegate>)mp4FileTagTable];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void)awakeFromNib
{
	[[self mp4FileTagTableView] registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]]; 
}

- (IBAction)addMp4Click:(id)sender {
	NSOpenPanel* oDlg = [NSOpenPanel openPanel];
    [oDlg setCanChooseFiles:YES];
	[oDlg setAllowsMultipleSelection:YES];
	[oDlg setCanChooseDirectories:NO];
    [oDlg setCanCreateDirectories:NO];
    [oDlg beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSArray* urls = [oDlg URLs];
			[mp4FileTagTable addMp4Files:urls atIndex:-1];
			urls = nil;
        }
    }];
}

- (IBAction)removeMp4Click:(id)sender {
	if([[self mp4FileTagTableView] selectedRow] >= 0) 
		[mp4FileTagTable removeMp4FileTagAt:[[self mp4FileTagTableView] selectedRow]];
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a file first.",
						@"OK", nil, nil);
		
}

- (IBAction)saveMp4Click:(id)sender {
	int idx = [[self mp4FileTagTableView] selectedRow];
	if(idx >= 0) 
		[mp4FileTagTable saveMp4FileTagAt:idx];
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a file first.",
						@"OK", nil, nil);
}

- (IBAction)saveAllMp4Click:(id)sender {
	if([[mp4FileTagTable mp4tags] count] > 0)
		[mp4FileTagTable saveAllMp4FileTags];
	else
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please add a file first.",
						@"OK", nil, nil);
}

- (IBAction)selectImageClick:(id)sender {
	int idx = [[self mp4FileTagTableView] selectedRow];
	if(idx >= 0) {
		NSOpenPanel* oDlg = [NSOpenPanel openPanel];
		[oDlg setCanChooseFiles:YES];
		[oDlg setAllowsMultipleSelection:NO];
		[oDlg setCanChooseDirectories:NO];
		[oDlg setCanCreateDirectories:NO];
		[oDlg beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
			if (result == NSFileHandlingPanelOKButton)
			{
				NSArray* urls = [oDlg URLs];
				NSString* imgfn = [[urls objectAtIndex:0] path ];
				if([[imgfn pathExtension] compare:@"jpg" options:NSCaseInsensitiveSearch] == 0)
				{
					POPMp4FileTag* tag = [[mp4FileTagTable mp4tags] objectAtIndex:idx];
					[tag setImage:[[NSImage alloc] initWithContentsOfFile:imgfn]];
					[mp4FileTagTable reloadAll];
				}
			}
		}];
	}
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a file first.",
						@"OK", nil, nil);
}

-(bool) autotagNext {
	if(attags_idx < [attags count]) {
		POPMp4FileTag* tag = [attags objectAtIndex:attags_idx];
		[[self seachFilenameLabel] setStringValue:[tag filename]];
		[[self searchTableView] setDataSource:nil];
		[[self searchTableView] reloadData];
		[_loadWnd show:[NSString stringWithFormat:@"Searching for %@...", [tag filename]]];
		if([[self customSearchWindowUseSameSeriesCheckBox] state])
		{
			[tag setProperty:@"TV Show" value:[[self customSearchWindowSeriesTextField] stringValue]];
			[tag setCustomSeriesSearch:YES];
		}
		mp4SearchFileTagTable = [[POPMp4FileTagSearch alloc] init];
		[mp4SearchFileTagTable searchWithFileTag:tag tableView:[self searchTableView]];
		[_loadWnd hide];
		attags_idx = attags_idx + 1;
		return true;
	}
	[[NSApplication sharedApplication] endSheet:[self searchResultWindow] returnCode:0];
	[[self searchResultWindow] close];
	return false;
}

-(void) autotag {
	[[self customSearchWindowUseSameSeriesCheckBox] setState:NO];
	[[NSApplication sharedApplication] beginSheet:[self searchResultWindow] 
								   modalForWindow:[self window]
									modalDelegate:self
								   didEndSelector:@selector(searchResultSheetEnded:returnCode:contextInfo:) 
									  contextInfo:(void*)[self searchResultWindow]];
	[self autotagNext];
}
- (IBAction)autotagSelectedClick:(id)sender {
	int idx = [[self mp4FileTagTableView] selectedRow];
	if(idx >= 0) {
		POPMp4FileTag* tag = [[mp4FileTagTable mp4tags] objectAtIndex:idx];
		
		attags = [NSArray arrayWithObject:tag];
		attags_idx = 0;
		[self autotag];
	}
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a file first.",
						@"OK", nil, nil);
}

- (IBAction)searchResultWindowSearchClick:(id)sender {
	if(mp4SearchFileTagTable != nil)
	{
		if([mp4SearchFileTagTable isMovie]) {
			[[self customSearchWindowTabView] selectTabViewItemAtIndex:1];
			[[self customSearchWindowMovieTextField] setStringValue:[mp4SearchFileTagTable searchString]];
		}
		else {
			[[self customSearchWindowTabView] selectTabViewItemAtIndex:0];
			[[self customSearchWindowSeriesTextField] setStringValue:[mp4SearchFileTagTable seriesString]];
			[[self customSearchWindowSeasonNumberTextField] setStringValue:[mp4SearchFileTagTable seasonString]];
			[[self customSearchWindowEpisodeNumberTextField] setStringValue:[mp4SearchFileTagTable episodeString]];
		}
		
	}
	[[NSApplication sharedApplication] beginSheet:[self customSearchWindow] 
								   modalForWindow:[self searchResultWindow]
									modalDelegate:self
								   didEndSelector:@selector(customSearchSheetEnded:returnCode:contextInfo:) 
									  contextInfo:(void*)[self customSearchWindow]];
}

- (IBAction)autotagAllClick:(id)sender {
	attags = [mp4FileTagTable mp4tags];
	attags_idx = 0;
	if([attags count] > 0)
		[self autotag];
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please add a file first.",
						@"OK", nil, nil);
}

- (IBAction)customSearchWindowSearchClick:(id)sender {
	if(mp4SearchFileTagTable != nil) {
		mp4SearchFileTagTable = nil;
	}
	mp4SearchFileTagTable = [[POPMp4FileTagSearch alloc] init];
	
	POPMp4FileTag* tag = [[POPMp4FileTag alloc] init];
	if([[[[self customSearchWindowTabView] selectedTabViewItem] label] compare:@"TV Search"] == 0) {
		[tag setProperty:@"Media Type" value:@"tvshow"];
		[tag setProperty:@"TV Show" value:[[self customSearchWindowSeriesTextField] stringValue]];
		[tag setProperty:@"TV Season" value:[[self customSearchWindowSeasonNumberTextField] stringValue]];
		[tag setProperty:@"TV Episode" value:[[self customSearchWindowEpisodeNumberTextField] stringValue]];
		[tag setCustomSeriesSearch:YES];
		[_loadWnd show:[NSString stringWithFormat:@"Searching for TV Show: %@\nSeason: %@\nEpisode: %@", [tag property:@"TV Show"], [tag property:@"TV Season"], [tag property:@"TV Episode"]]];
	}
	else {
		[tag setProperty:@"Media Type" value:@"movie"];
		[tag setProperty:@"Name" value:[[self customSearchWindowMovieTextField] stringValue]];
		[_loadWnd show:[NSString stringWithFormat:@"Searching for Movie: %@", [tag property:@"Name"], [tag property:@"Name"]]];
	}
	
	[mp4SearchFileTagTable searchWithFileTag:tag
								   tableView:[self searchTableView]];
	[_loadWnd hide];
	[[NSApplication sharedApplication] endSheet:[self customSearchWindow] returnCode:0];
	[[self customSearchWindow] close];
}

- (IBAction)customSearchWindowCloseClick:(id)sender {
	[[NSApplication sharedApplication] endSheet:[self customSearchWindow] returnCode:0];
	[[self customSearchWindow] close];
}

- (IBAction)searchDoneClick:(id)sender {
	[[NSApplication sharedApplication] endSheet:[self searchResultWindow] returnCode:0];
	[[self searchResultWindow] close];
}

- (IBAction)searchSkipClick:(id)sender {
	[self autotagNext];
}

- (IBAction)searchTagClick:(id)sender {
	int idx = [[self searchTableView] selectedRow];
	if(idx >= 0){
		[_loadWnd show:@"Merging tag..."];
		POPMp4FileTag* otag = [attags objectAtIndex:attags_idx-1];
		POPMp4FileTag* ntag = [mp4SearchFileTagTable chooseResult:idx];
		if(ntag != nil)
		{
			[otag mergeData:ntag];
		}
		[_loadWnd hide];
		[self autotagNext];
	}
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a result first.",
						@"OK", nil, nil);
}

- (IBAction)searchTagSaveClick:(id)sender {
	int idx = [[self searchTableView] selectedRow];
	if(idx >= 0){
		POPMp4FileTag* otag = [attags objectAtIndex:attags_idx-1];
		POPMp4FileTag* ntag = [mp4SearchFileTagTable chooseResult:idx];
		if(ntag != nil)
		{
		[_loadWnd show:[NSString stringWithFormat:@"Merging tag and saving ...\"%@\"", [otag filename]]]; 
			[otag mergeData:ntag];
			[otag save];
			[_loadWnd hide];
		}
		[self autotagNext];
	}
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a result first.",
						@"OK", nil, nil);
}

- (IBAction)searchTagSaveRenameClick:(id)sender {
	int idx = [[self searchTableView] selectedRow];
	if(idx >= 0){
		POPMp4FileTag* otag = [attags objectAtIndex:attags_idx-1];
		POPMp4FileTag* ntag = [mp4SearchFileTagTable chooseResult:idx];
		if(ntag != nil)
		{
			[_loadWnd show:[NSString stringWithFormat:@"Merging tag and saving ...\"%@\"\nRename to...\"%@\"", [otag filename], [NSString stringWithFormat:@"%@.mp4", [ntag property:@"Name"]]]];
			[otag mergeData:ntag];
			[otag save];
			[otag rename];
			[_loadWnd hide];
		}
		[self autotagNext];
	}
	else 
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Please select a result first.",
						@"OK", nil, nil);
}

- (void)searchResultSheetEnded:(NSNotification *)notification returnCode:(NSInteger)rtnCode contextInfo:(NSObject*)cInfo
{
	[mp4FileTagTable reloadAll];
}

- (void)customSearchSheetEnded:(NSNotification *)notification returnCode:(NSInteger)rtnCode contextInfo:(NSObject*)cInfo
{
	
}
@end





















