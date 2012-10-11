//
//  POPAppDelegate.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "POPLoadingWindow.h"
#import "POPMp4FileTag.h"
#import "POPMp4FileTagTable.h"

@interface POPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet POPLoadingWindow *loadWnd;
@property (weak) IBOutlet NSTableView *mp4FileTagTableView;
@property (weak) IBOutlet NSTableView *mp4FileTagView;
@property (weak) IBOutlet NSTextField *currentFilenameLabel;
@property (weak) IBOutlet NSImageCell *mp4FileTagImage;
@property (unsafe_unretained) IBOutlet NSWindow *searchResultWindow;
@property (unsafe_unretained) IBOutlet NSWindow *customSearchWindow;
@property (weak) IBOutlet NSTableView *searchTableView;
@property (weak) IBOutlet NSTextField *seachFilenameLabel;
@property (weak) IBOutlet NSTabView *customSearchWindowTabView;
@property (weak) IBOutlet NSTextField *customSearchWindowSeriesTextField;
@property (weak) IBOutlet NSTextField *customSearchWindowSeasonNumberTextField;
@property (weak) IBOutlet NSTextField *customSearchWindowEpisodeNumberTextField;
@property (weak) IBOutlet NSTextField *customSearchWindowMovieTextField;
@property (weak) IBOutlet NSButton *customSearchWindowUseSameSeriesCheckBox;

- (IBAction)addMp4Click:(id)sender;
- (IBAction)removeMp4Click:(id)sender;
- (IBAction)saveMp4Click:(id)sender;
- (IBAction)saveAllMp4Click:(id)sender;
- (IBAction)selectImageClick:(id)sender;
- (IBAction)autotagSelectedClick:(id)sender;
- (IBAction)searchResultWindowSearchClick:(id)sender;
- (IBAction)searchTagClick:(id)sender;
- (IBAction)searchDoneClick:(id)sender;
- (IBAction)searchSkipClick:(id)sender;
- (IBAction)searchTagSaveClick:(id)sender;
- (IBAction)searchTagSaveRenameClick:(id)sender;
- (IBAction)autotagAllClick:(id)sender;
- (IBAction)customSearchWindowSearchClick:(id)sender;
- (IBAction)customSearchWindowCloseClick:(id)sender;

@end