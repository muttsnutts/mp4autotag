//
//  POPMp4FileTagSearch.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/30/12.
//  Copyright (c) 2012 The Popmedic. All rights reserved.
//

#import "POPMp4FileTagSearch.h"
#import "POPTMDB.h"
#import "POPTVDB.h"

@implementation POPMp4FileTagSearch
{
	NSArray* results;
	NSTableView* tableView;	
	POPTMDB* tmdb;
	POPTVDB* tvdb;
	NSString *epistr;
	NSString *seastr;
	NSString *serstr;
	NSString* search_str;
}

@synthesize isMovie = _isMovie;

-(id) init {
	epistr = @"1";
	seastr = @"1";
	serstr = @"";
	results = [NSArray array];
	return [super init];
}

-(NSString*) episodeString{return epistr;}
-(NSString*) seasonString{return seastr;}
-(NSString*) seriesString{return serstr;}
-(NSString*) searchString{return search_str;}

-(id) searchWithFileTag:(POPMp4FileTag *)tag 
			tableView:(NSTableView*)tv {
	NSError *error;
	NSRegularExpression* rgx;	
	tableView = tv;
	results = [NSArray array];
	_isMovie = true;
	tmdb = nil;
	epistr = @"1";
	seastr = @"1";
	serstr = @"";
	[tableView setDataSource:(id<NSTableViewDataSource>)self];	
	
	if([[tag filename] compare:@""] == 0) {
		//start search logic for custom search...
		if([tag property:@"Media Type"] == @"tvshow")
		{
			_isMovie = false;
			serstr = [tag property:@"TV Show"];
			seastr = [tag property:@"TV Season"];
			epistr = [tag property:@"TV Episode"];
		}
		else {
			_isMovie = true;
			search_str = [tag property:@"Name"];
		}
	}
	else {
		//set the search string by the filename.
		search_str = [[[tag filename] lastPathComponent] stringByDeletingPathExtension];
		search_str = [search_str stringByReplacingOccurrencesOfString:@"." withString:@" "];
		search_str = [search_str stringByReplacingOccurrencesOfString:@"_" withString:@" "];
		
		//start search logic for file name...
		//if file is of type /.*\([0-9]{4}\) *\.mp4$/ then it is a movie
		 rgx = [NSRegularExpression regularExpressionWithPattern:@"^.*[\\( ][0-9]{4}\\){0,1} *$" 
														 options:NSRegularExpressionCaseInsensitive 
														   error:&error];
		int nm = [rgx numberOfMatchesInString:search_str 
									  options:0 
										range:NSMakeRange(0, [search_str length])];
		if(nm) {
			//we have a definate movie
			_isMovie = true;
		}
		else {
			//set default series string
			serstr = [tag property:@"TV Show"];
			
			//broad sweep for tvshow...
			rgx = [NSRegularExpression regularExpressionWithPattern:@"E[0-9]+"
															options:NSRegularExpressionCaseInsensitive
															  error:&error];
			nm = [rgx numberOfMatchesInString:search_str
									  options:0
										range:NSMakeRange(0, [search_str length])];
			if(nm) {
				//we might have a tvshow... lets get the supposed episode#
				NSArray* m = [rgx matchesInString:search_str
										  options:0
											range:NSMakeRange(0, [search_str length])];
				epistr = [search_str substringWithRange:[[m objectAtIndex:0] range]];
				epistr = [epistr substringFromIndex:1];
				
				//see if we have a series name... lets get it.
				rgx = [NSRegularExpression regularExpressionWithPattern:@"\\-{0,1} {0,1}([SE]{1}[0-9]+){1,2} {0,1}\\-{0,1}"
																options:NSRegularExpressionCaseInsensitive
																  error:&error];
				nm = [rgx numberOfMatchesInString:search_str 
										  options:0
											range:NSMakeRange(0, [search_str length])];
				if(nm) {
					m = [rgx matchesInString:search_str
									 options:0
									   range:NSMakeRange(0, [search_str length])];
					if(![tag customSeriesSearch])
						serstr = [[search_str substringWithRange:NSMakeRange(0, [[m objectAtIndex:0] range].location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				}
				
				//see if we have a season... lets get the season#
				rgx = [NSRegularExpression regularExpressionWithPattern:@"S[0-9]+E[0-9]+"
																options:NSRegularExpressionCaseInsensitive
																  error:&error];
				nm = [rgx numberOfMatchesInString:search_str 
										  options:0
											range:NSMakeRange(0, [search_str length])];
				if(nm) {
					m = [rgx matchesInString:search_str
									 options:0
									   range:NSMakeRange(0, [search_str length])];
					seastr = [search_str substringWithRange:[[m objectAtIndex:0] range]];
					seastr = [seastr substringWithRange:NSMakeRange(1, [seastr rangeOfString:@"E" options:NSCaseInsensitiveSearch].location - 1)];
				}
				
				//did we get a series name???
				if([serstr compare:@""] == 0)
				{
					//well then get it from the parent directories...
					NSString* pdir = [[[tag filename] stringByDeletingLastPathComponent] lastPathComponent];
					rgx = [NSRegularExpression regularExpressionWithPattern:@"Season" 
																	options:NSRegularExpressionCaseInsensitive error:&error];
					nm = [rgx numberOfMatchesInString:pdir
											  options:0
												range:NSMakeRange(0, [pdir length])];
					if(nm) {
						if(seastr == @"1")
						{
							m = [rgx matchesInString:pdir
											 options:0
											   range:NSMakeRange(0, [pdir length])];
							NSString* t = [[pdir substringFromIndex:[[m objectAtIndex:0] range].location + [[m objectAtIndex:0] range].length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
							if([t intValue] > 1){
								seastr = t;
							}
						}
						pdir = [[[[tag filename] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] lastPathComponent];	
					}
					serstr = pdir;
				}
				
				//now if we have a serstr we can do a tv search!!!
				if([serstr compare:@""] != 0){
					_isMovie = false;
				}
			}
		}
	}
	if(_isMovie){
		tmdb = [[POPTMDB alloc] init];
		results = [tmdb searchMoviesFor:search_str];
	}
	else {
		tvdb = [[POPTVDB alloc] init];
		results = [tvdb searchTVFor:serstr season:seastr episode:epistr];
	}
	/*if([results count] == 0) {
		NSRunAlertPanel(@"Mp4Autotag", 
						@"Unable to find movie/show in databases, try a custom search.",
						@"OK", nil, nil);
	}
	else {*/
		[tableView reloadData];
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	//}
	return results;
}

-(POPMp4FileTag*) chooseResult:(int)idx {
	if(idx < [results count]){
		if(_isMovie && tmdb != nil)
		{
			return [tmdb getMp4FileTagWithId:[[results objectAtIndex:idx] dbID]];
		}
		else
		{
			return [results objectAtIndex:idx];
		}
	}
	return nil;
}

-(void) reload {
	if(tableView != nil)
		[tableView reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [results count];
}

- (id)tableView:(NSTableView*)aTableView 
objectValueForTableColumn:(NSTableColumn*)aTableColumn 
			row:(NSInteger)rowIndex
{
	NSString* colheadstr = [[aTableColumn headerCell] stringValue];
	POPMp4FileTag* tag = [results objectAtIndex:rowIndex];
	if([colheadstr compare:@"Image"] == 0){
		NSImage* img = [tag image];
		return img;
	}
	else {
		return [[[tag properties] objectForKey:colheadstr] objectForKey:@"value"];
	}
	return nil;
}
@end









