//
//  RecentsCDTVC.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/18/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "RecentsCDTVC.h"
#import "Photo.h"
#import "AppDelegate.h"

@interface RecentsCDTVC ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation RecentsCDTVC

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
	if (error) NSLog(@"%@", error);
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[(AppDelegate *)[UIApplication sharedApplication].delegate addObserver:self forKeyPath:@"managedObjectContext" options:NSKeyValueObservingOptionInitial context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"managedObjectContext"] && object == [UIApplication sharedApplication].delegate) {
		self.managedObjectContext = ((AppDelegate *)object).managedObjectContext;
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#define RECENT_LIST_MAXIMUM 5

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	_managedObjectContext = managedObjectContext;
	if (managedObjectContext) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastAccessed" ascending:NO]];
		request.predicate = [NSPredicate predicateWithFormat:@"lastAccessed != nil"];
		[request setFetchLimit:RECENT_LIST_MAXIMUM];
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	} else {
		self.fetchedResultsController = nil;
	}
}

@end
