//
//  Tag+Create.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context {
	Tag *tag = nil;
	
	if ([name length]) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
		request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
		
		NSError *error;
		NSArray *matches = [context executeFetchRequest:request error:&error];
		
		if (![matches count]) {
			tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
			tag.name = name;
		} else {
			tag = [matches lastObject];
		}
	}
	
	return tag;
}

@end
