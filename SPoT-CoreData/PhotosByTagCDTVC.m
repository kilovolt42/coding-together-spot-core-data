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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
	
	Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = photo.title;
	cell.detailTextLabel.text = photo.information;
	
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *indexPath = nil;
	
	if ([sender isKindOfClass:[UITableViewCell class]]) {
		indexPath = [self.tableView indexPathForCell:sender];
	}
	
	if (indexPath) {
		if ([segue.identifier isEqualToString:@"setImageURL:"]) {
			Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
			if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
				NSURL *url = [NSURL URLWithString:photo.photoURL];
				[segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
				[segue.destinationViewController setTitle:photo.title];
			}
		}
	}
}

@end
