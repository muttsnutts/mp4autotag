//
//  POPAutomatedAutotagPropertyView.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 11/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPAutomatedAutotagPropertyView.h"
#import "POPMp4FileTag.h"

@implementation POPAutomatedAutotagPropertyView
{
	POPMp4FileTag* _otag;
	POPMp4FileTag* _ntag;
	NSArray* _properties;
}

- (id)init
{
	POPAutomatedAutotagPropertyView* rtn = [super init];
	[rtn setProperties:[NSArray array]];
	return rtn;
}

- (void) setProperties:(NSArray *)properties
{
	_properties = properties;
	_otag = nil;
	_ntag = nil;
	if([properties count] > 0)
	{
		_otag = [_properties objectAtIndex:0];
	}
	if([properties count] > 1)
	{
		_ntag = [_properties objectAtIndex:1];
	}
}

- (NSArray*) properties
{
	return _properties;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(_otag != nil) return [[[_otag properties] allKeys] count];
	return 0;
}

- (id)tableView:(NSTableView*)aTableView 
objectValueForTableColumn:(NSTableColumn*)aTableColumn 
			row:(NSInteger)rowIndex
{
	NSString* colident = [aTableColumn identifier];
	if (_otag != nil)
	{
		NSDictionary* dic = [_otag properties];
		NSArray* keys = [dic allKeys];
		NSString* key = [keys objectAtIndex:rowIndex];
		if([colident compare:@"AutotagAllTagName"] == 0){
			return key;
		}
		else if([colident compare:@"OriginalTag"] == 0){
			return [_otag property:key];
		}
		else if([colident compare:@"NewTag"] == 0){
			if(_ntag != nil) 
			{
				NSTextFieldCell* cell = [aTableColumn dataCellForRow:rowIndex];
				NSString* oval = [[_otag property:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSString* nval = [[_ntag property:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if([oval compare:nval] != 0)
				{
					[cell setDrawsBackground:YES];
					[cell setBackgroundColor:[NSColor orangeColor]];
					[cell setTextColor:[NSColor whiteColor]];
				}
				else {
					[cell setBackgroundColor:[NSColor textBackgroundColor]];
					[cell setTextColor:[NSColor textColor]];
					[cell setDrawsBackground:NO];
				}
				return [_ntag property:key];
			}
			return nil;
		}
	}
	return nil;
}
@end
