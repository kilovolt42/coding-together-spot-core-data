//
//  PhotosCDTVC.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/19/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"

@implementation PhotosCDTVC

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
				photo.lastAccessed = [NSDate date];
			}
		}
	}
}

@end
