//
//  TagsCoreDataTableViewController.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "TagsCDTVC.h"
#import "Tag.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "AppDelegate.h"

@interface TagsCDTVC ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation TagsCDTVC

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
	[(AppDelegate *)[UIApplication sharedApplication].delegate addObserver:self forKeyPath:@"managedObjectContext" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"managedObjectContext"] && object == [UIApplication sharedApplication].delegate) {
		self.managedObjectContext = ((AppDelegate *)object).managedObjectContext;
		if ([self.fetchedResultsController.fetchedObjects count] == 0) [self refresh];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	_managedObjectContext = managedObjectContext;
	if (managedObjectContext) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
		request.predicate = nil;
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	} else {
		self.fetchedResultsController = nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag"];
	
	Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [tag.name capitalizedString];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", [tag.photos count], ([tag.photos count] == 1) ? @"" : @"s"];
	
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *indexPath = nil;
	
	if ([sender isKindOfClass:[UITableViewCell class]]) {
		indexPath = [self.tableView indexPathForCell:sender];
	}
	
	if (indexPath) {
		if ([segue.identifier isEqualToString:@"setTag:"]) {
			Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
			if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
				[segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
			}
		}
	}
}

@end
