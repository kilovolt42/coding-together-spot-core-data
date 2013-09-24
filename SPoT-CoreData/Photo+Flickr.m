//
//  Photo+Flickr.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
	Photo *photo = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];
	
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	if (error) NSLog(@"%@", error);
	
	if (![matches count]) {
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
		photo.information = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
		photo.unique = [photoDictionary[FLICKR_PHOTO_ID] description];
		photo.largePhotoURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
		photo.originalPhotoURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatOriginal] absoluteString];
		photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
		photo.lastAccessed = nil;
		NSArray *tags = [photoDictionary[FLICKR_TAGS] componentsSeparatedByString:@" "];
		for (NSString *tagName in tags) {
			if (![tagName isEqualToString:@"cs193pspot"] && ![tagName isEqualToString:@"portrait"] && ![tagName isEqualToString:@"landscape"]) {
				Tag *tag = [Tag tagWithName:tagName inManagedObjectContext:context];
				[photo addTagsObject:tag];
			}
		}
	} else {
		photo = [matches lastObject];
	}
	
	return photo;
}

@end
