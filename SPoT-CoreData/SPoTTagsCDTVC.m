//
//  SPoTTagsCoreDataTableViewController.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "SPoTTagsCDTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@implementation SPoTTagsCDTVC

- (IBAction)refresh {
	[self.refreshControl beginRefreshing];
	dispatch_queue_t fetchQueue = dispatch_queue_create("Flickr fetch queue", NULL);
	dispatch_async(fetchQueue, ^{
		NSArray *photos = [FlickrFetcher stanfordPhotos];
		[self.managedObjectContext performBlock:^{
			for (NSDictionary *photo in photos) {
				[Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.refreshControl endRefreshing];
			});
		}];
	});
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!self.managedObjectContext) [self useSPoTDocument];
}

- (void)useSPoTDocument {
	NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	url = [url URLByAppendingPathComponent:@"SPoT Document"];
	UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
		[document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
			if (success) {
				self.managedObjectContext = document.managedObjectContext;
				[self refresh];
			}
		}];
	} else if (document.documentState == UIDocumentStateClosed) {
		[document openWithCompletionHandler:^(BOOL success) {
			if (success) {
				self.managedObjectContext = document.managedObjectContext;
			}
		}];
	} else {
		self.managedObjectContext = document.managedObjectContext;
	}
}

@end
