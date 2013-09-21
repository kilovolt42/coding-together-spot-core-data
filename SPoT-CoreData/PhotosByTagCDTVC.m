//
//  PhotosCDTVC.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "PhotosByTagCDTVC.h"
#import "Photo.h"

@implementation PhotosByTagCDTVC

- (void)setTag:(Tag *)tag {
	_tag = tag;
	self.title = [tag.name capitalizedString];
	[self setupFetchedResultsController];
}

- (void)setupFetchedResultsController {
	if (self.tag.managedObjectContext) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
		request.predicate = [NSPredicate predicateWithFormat:@"tags contains %@", self.tag];
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.tag.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	} else {
		self.fetchedResultsController = nil;
	}
}

@end
