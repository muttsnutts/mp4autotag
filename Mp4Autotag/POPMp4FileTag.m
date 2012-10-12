//
//  POPMp4FileTag.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "POPMp4FileTag.h"
#import "POPFileMan.h"
#import "POPTask.h"
#import "POPImage.h"

@implementation POPMp4FileTag
{
	NSArray* keysOrder;
	NSArray* numFlags;
	NSArray* allowedMediaTypes;
}

@synthesize properties = _properties;
@synthesize filename = _filename;
@synthesize coverArtPieces = _coverArtPieces;
@synthesize image = _image;
@synthesize dbID = _dbID;
@synthesize customSeriesSearch = _customSeriesSearch;

-(id) init {
	_filename = @"";
	_coverArtPieces = 0;
	_image = nil;
	_dbID = 0;
	_customSeriesSearch = NO;
	numFlags = [NSArray arrayWithObjects:@"-b", @"-d",@"-D",@"-H",@"-I",@"-l",@"-L",@"-M",@"-n",@"-t",@"-T",@"-y", nil];
	allowedMediaTypes = [NSArray arrayWithObjects:@"tvshow", @"movie", @"music", nil];
	keysOrder = [NSArray arrayWithObjects:
				 @"Name",
				 @"Media Type",
				 @"TV Show",
				 @"Release Date",
				 @"Genre",
				 @"Grouping",
				 @"TV Episode",
				 @"TV Season",
				 @"TV Episode Number",
				 @"TV Network",
				 @"Short Description",
				 @"Long Description",
				 @"Album",
				 @"Artist",
				 @"Album Artist",
				 @"Composer",
				 @"Track",
				 @"Tracks",
				 @"Disk",
				 @"Disks",
				 @"BPM",
				 @"Copyright",
				 @"Comments",
				 @"HD Video",
				 @"Encoded with",
				 @"Encoded by",
				 @"cnID",
				 @"Lyrics",
				 nil];
	_properties = 
		[NSDictionary dictionaryWithObjects:
			[NSArray arrayWithObjects:
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-s", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-a", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-w", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-E", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-e", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-y", @"0", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-A", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-t", @"1", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-T", @"1", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-d", @"1", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-D", @"1", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-g", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-G", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-b", @"0", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-c", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-R", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-C", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-H", @"1", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-i", @"Movie", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-S", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-N", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-o", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-m", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-l", @"0", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-M", @"0", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-n", @"0", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-I", @"0", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-L", @"", nil]
										  forKeys:[NSArray arrayWithObjects:@"flag", @"value", nil]],
				nil
			]
									forKeys:
			[NSArray arrayWithObjects:
				@"Name",
				@"Artist",
				@"Composer",
				@"Encoded with",
				@"Encoded by",
				@"Release Date",
				@"Album",
				@"Track",
				@"Tracks",
				@"Disk",
				@"Disks",
				@"Genre",
				@"Grouping",
				@"BPM",
				@"Comments",
				@"Album Artist",
				@"Copyright",
				@"HD Video",
				@"Media Type",
				@"TV Show",
				@"TV Network",
				@"TV Episode Number",
				@"Short Description",
				@"Long Description",
				@"TV Episode",
				@"TV Season",
				@"cnID",
				@"Lyrics",
				nil
			]
		];
	
	return [super init];
}

-(id) initWithFile:(NSString*)filename {
	if(![[NSFileManager defaultManager] fileExistsAtPath:filename])
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException" 
									   reason:[NSString stringWithFormat: @"File \"%@\" Not Found on System", filename] 
									 userInfo:nil];
	}
	
	POPMp4FileTag* rtn = [self init];
	_filename = filename;
	NSString* mp4info_path = [[NSBundle mainBundle] pathForResource:@"mp4info" ofType:nil];
	NSLog(@"mp4info path: %@", mp4info_path);
	NSError *error;
	NSString *info = [POPTask launchedWithLaunchPathAndWaitReturnStdio:mp4info_path options:[NSArray arrayWithObjects: filename, nil]];
	NSLog(@"%@",info);
	NSRegularExpression *rgx = [NSRegularExpression regularExpressionWithPattern:@"can\\\'t open" options:NSRegularExpressionCaseInsensitive error:&error];
	if([rgx numberOfMatchesInString:info options:0 range:NSMakeRange(0, [info length])]) {
		NSString* reason = [NSString stringWithFormat: @"Unable to open file: \"%@\"", _filename];
		@throw [NSException exceptionWithName:@"FileNotMp4" 
									   reason:reason
									 userInfo:nil];
	}
	[info enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop) {
		if(line != nil) {
			if([line characterAtIndex:0] == ' ')
			{
				NSArray* kvpair = [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@":"];
				if([kvpair count] == 2) {
					NSString* key = [[kvpair objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					NSString* value = [[kvpair objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
					NSMutableDictionary* prop = [[rtn properties] valueForKey:key];
					
					if(prop != nil) {
						[self setProperty:key value:value];
						[prop setObject:value forKey:@"value"];
					}
					else {
						NSLog(@"No property with key: %@",key);
					}
					
					if([key compare:@"Cover Art pieces"] == 0)
					{
						[rtn setCoverArtPieces:[value intValue]];
					}
					else if ([key compare:@"HD Video"] == 0) {
						if([value compare:@"yes" options:NSCaseInsensitiveSearch] == 0) {
							[[[rtn properties] valueForKey:key] setObject:@"1" forKey:@"value"];
						}
						else {
							[[[rtn properties] valueForKey:key] setObject:@"0" forKey:@"value"];
						}
					}
					else if ([key compare:@"Track"] == 0 || [key compare:@"Disk"] == 0) {
						NSArray* pair = [value componentsSeparatedByString:@" of "];
						if([pair count] == 2) {
							NSString* a = [pair objectAtIndex:0];
							NSString* b = [pair objectAtIndex:1];
							NSString* s = [NSString stringWithFormat:@"%@s", key];
							[[[rtn properties] valueForKey:key] setObject:a forKey:@"value"];
							[[[rtn properties] valueForKey:s] setObject:b forKey:@"value"];
						}
					}
					else if ([key compare:@"Media Type"] == 0) {
						if([value compare:@"TV Show"] == 0) 
							[[[rtn properties] valueForKey:key] setObject:@"tvshow" forKey:@"value"];
						else if ([value compare:@"Movie"] == 0) 
							[[[rtn properties] valueForKey:key] setObject:@"movie" forKey:@"value"];
						else if ([value compare:@"Music"] == 0) 
							[[[rtn properties] valueForKey:key] setObject:@"music" forKey:@"value"];
						else
							[[[rtn properties] valueForKey:key] setObject:@"" forKey:@"value"];
					}
				}
				else {
					NSLog(@"Not a valid property string: %@", line);
				}
			}	
		}
	}];
	
	if([rtn coverArtPieces] > 0)
	{
		info = [POPTask launchedWithLaunchPathAndWaitReturnStdio:[[NSBundle mainBundle] pathForResource:@"mp4art" ofType:nil] options:[NSArray arrayWithObjects: @"--extract", filename, nil]];
		NSString* imgfn = nil;
		if([[NSFileManager defaultManager] fileExistsAtPath:[[filename stringByDeletingPathExtension] stringByAppendingString:@".art[0].jpg"]])
		{
			imgfn = [[filename stringByDeletingPathExtension] stringByAppendingString:@".art[0].jpg"];
		}
		else if ([[NSFileManager defaultManager] fileExistsAtPath:[[filename stringByDeletingPathExtension] stringByAppendingString:@".art[0].png"]])
		{
			imgfn = [[filename stringByDeletingPathExtension] stringByAppendingString:@".art[0].png"];
		}
		if(imgfn != nil) {
			NSError *error;
			[rtn setImage:[[NSImage alloc] initWithContentsOfFile:imgfn]];
			[[NSFileManager defaultManager] removeItemAtPath:imgfn error:&error];
		}
	}
	return rtn;
}

-(NSString*) property:(NSString*)prop {
	return [[_properties valueForKey:prop] valueForKey:@"value"];
}

-(bool) setProperty:(NSString*)prop value:(NSString*)val {
	if(val != nil && [val isKindOfClass:[NSString class]]){
		NSString* flag = [[_properties valueForKey:prop] valueForKey:@"flag"];
		if([numFlags containsObject:flag]){
			val = [NSString stringWithFormat:@"%i", [val intValue]];
		}
		if([prop compare:@"Media Type"] == 0){
			if(![allowedMediaTypes containsObject:val]){
				val = @"movie";
			}
		}
		[[_properties valueForKey:prop] setValue:[val stringByReplacingOccurrencesOfString:@":" withString:@"-"] forKey:@"value"];
		return true;
	}
	return false;
}

-(bool) save {
	NSError* error;
	NSMutableArray* opts = [[NSMutableArray alloc] initWithCapacity:1];
	for(int i = 0; i < [[_properties allValues] count]; i++)
	{
		NSDictionary* fvpair = [[_properties allValues] objectAtIndex:i];
		NSString* flag = [fvpair valueForKey:@"flag"];
		NSString* value = [fvpair valueForKey:@"value"];
		[opts addObject:flag];
		[opts addObject:value];
	}
	[opts addObject:_filename];
	NSString* mp4tags_path = [[NSBundle mainBundle] pathForResource:@"mp4tags" ofType:nil];
	NSString *info = [POPTask launchedWithLaunchPathAndWaitReturnStdio:mp4tags_path options:opts];
	NSLog(@"%@ %@\n%@", mp4tags_path, [opts componentsJoinedByString:@" "], info);
	
	NSRegularExpression* rgx = [NSRegularExpression regularExpressionWithPattern:@"^Could not open " options:NSRegularExpressionCaseInsensitive error:&error];

	if([rgx numberOfMatchesInString:info options:0 range:NSMakeRange(0, [info length])]) {
		return false;
	}
	
	if(_image != nil)
	{
		NSString* mp4art_path = [[NSBundle mainBundle] pathForResource:@"mp4art" ofType:nil];
		info = [POPTask launchedWithLaunchPathAndWaitReturnStdio:mp4art_path options:[NSArray arrayWithObjects:@"--remove", _filename, nil]];
		//NSLog(@"mp4art out: %@",info);
		
		NSString* tempfilename = [POPFileMan getTempFilePathWithExt:@"jpg"];
			
		[POPImage saveJpg:_image path:tempfilename];
			
		info = [POPTask launchedWithLaunchPathAndWaitReturnStdio:mp4art_path options:[NSArray arrayWithObjects:@"--add", tempfilename, _filename, nil]];
		//NSLog(@"mp4art out: %@",info);
		NSError* e;
		
		[[NSFileManager defaultManager] removeItemAtPath:tempfilename error:&e];
	}
	return true;
}

-(bool) rename {
	NSString* nn;
	NSError *error;
	if([self filename] != @"")
	{
		if([self property:@"Name"] != @"")
		{
			nn = [NSString stringWithFormat:@"%@/%@.mp4", [[self filename] stringByDeletingLastPathComponent], [self property:@"Name"]];
			if([[NSFileManager defaultManager] moveItemAtPath:[self filename] toPath:nn error:&error]){
				//special for me...
				NSString* obf = [[[self filename] stringByDeletingPathExtension] stringByAppendingString:@"-SD.bif"];
				NSString* nbf = [NSString stringWithFormat:@"%@/%@-SD.bif", [[self filename] stringByDeletingLastPathComponent], [self property:@"Name"]];
				if([[NSFileManager defaultManager] fileExistsAtPath:obf])
					[[NSFileManager defaultManager] moveItemAtPath:obf toPath:nbf error:&error];
				NSString* ojf = [[[self filename] stringByDeletingPathExtension] stringByAppendingString:@"-SD.jpg"];
				NSString* njf = [NSString stringWithFormat:@"%@/%@-SD.jpg", [[self filename] stringByDeletingLastPathComponent], [self property:@"Name"]];
				if([[NSFileManager defaultManager] fileExistsAtPath:ojf])
					[[NSFileManager defaultManager] moveItemAtPath:ojf toPath:njf error:&error];
				_filename = nn;
				return true;
			}
			else {
				NSLog(@"ERROR*** %@", [error description]);
			}
		}
	}
	return false;
}

-(bool) mergeData:(POPMp4FileTag*)data {
	if([data filename] != @"")
		_filename = [data filename];
	
	_coverArtPieces = [data coverArtPieces];
	[self setImage:[data image]];
	_dbID = [data dbID];
	
	for(int i = 0; i < [[_properties allKeys] count]; i++) {
		[self setProperty:[[_properties allKeys] objectAtIndex:i] value:[data property:[[_properties allKeys] objectAtIndex:i]]];
	}
	return true;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[_properties allKeys] count] + 1;
}

- (id)tableView:(NSTableView*)aTableView 
objectValueForTableColumn:(NSTableColumn*)aTableColumn 
			row:(NSInteger)rowIndex
{
	if(rowIndex < [[_properties allKeys] count])
	{
		if([[[aTableColumn headerCell] stringValue] compare:@"Tag"] == 0)
		{
			return [keysOrder objectAtIndex:rowIndex];
		}
		else {
			return [[_properties valueForKey:[keysOrder objectAtIndex:rowIndex]] valueForKey:@"value"];
		}
	}
	if([[[aTableColumn headerCell] stringValue] compare:@"Tag"] == 0)
	{
		return @"Filename";
	}
	else {
		return [self filename];
	}
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)rowIndex
{
	if(rowIndex < [[_properties allKeys] count])
	{
		if([[[aTableColumn headerCell] stringValue] compare:@"Tag"] != 0)
		{
			//[[_properties valueForKey:[keysOrder objectAtIndex:rowIndex]] setValue:anObject forKey:@"value"];
			[self setProperty:[keysOrder objectAtIndex:rowIndex] value:anObject];
		}
	}
	else {
		_filename = anObject;
	}
}
@end
