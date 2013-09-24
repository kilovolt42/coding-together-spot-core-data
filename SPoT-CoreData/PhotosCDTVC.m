//
//  PhotosCDTVC.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/19/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"
#import "IndicatorActivator.h"

@implementation PhotosCDTVC

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
	
	Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = photo.title;
	cell.detailTextLabel.text = photo.information;
	cell.imageView.image = nil;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	__block UIImage *thumbnail = [UIImage imageWithData:photo.thumbnailData];
	if (!thumbnail) {
		dispatch_queue_t thumbnail_download = dispatch_queue_create("thumbnail download", NULL);
		dispatch_async(thumbnail_download, ^{
			[IndicatorActivator activate];
			photo.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
			[IndicatorActivator deactivate];
			if (cell.window) {
				thumbnail = [UIImage imageWithData:photo.thumbnailData];
				dispatch_async(dispatch_get_main_queue(), ^{
					cell.imageView.image = thumbnail;
					[cell setNeedsLayout];
				});
			}
		});
	} else {
		cell.imageView.image = thumbnail;
		[cell setNeedsLayout];
	}
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
				NSURL *url;
				if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
					url = [NSURL URLWithString:photo.largePhotoURL];
				} else {
					url = [NSURL URLWithString:photo.originalPhotoURL];
				}
				[segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
				[segue.destinationViewController setTitle:photo.title];
				photo.lastAccessed = [NSDate date];
				if ([segue.destinationViewController respondsToSelector:@selector(setSplitViewBarButtonItem:)]) [self transferSplitViewBarButtonToViewController:segue.destinationViewController];
			}
		}
	}
}

- (id)splitViewDetailWithBarButtonItem {
	id detail = [self.splitViewController.viewControllers lastObject];
	if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] || ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
	return detail;
}

- (void)transferSplitViewBarButtonToViewController:(id)destinationViewController {
	UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] performSelector:@selector(splitViewBarButtonItem)];
	[[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
	if (splitViewBarButtonItem) [destinationViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:splitViewBarButtonItem];
}

#pragma mark - Split view delegate

- (void)awakeFromNib {
	self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
	return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)sender willHideViewController:(UIViewController *)master withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popover {
	barButtonItem.title = @"Photos";
	id detailViewController = [self.splitViewController.viewControllers lastObject];
	if ([detailViewController respondsToSelector:@selector(setSplitViewBarButtonItem:)]) {
		[detailViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:barButtonItem];
	}
}

- (void)splitViewController:(UISplitViewController *)sender willShowViewController:(UIViewController *)master invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	id detailViewController = [self.splitViewController.viewControllers lastObject];
	if ([detailViewController respondsToSelector:@selector(setSplitViewBarButtonItem:)]) {
		[detailViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
	}
}

@end
