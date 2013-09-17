//
//  TagsCoreDataTableViewController.h
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//
//  Can do "setTag:" segue and will call said method in destincation view controller.

#import "CoreDataTableViewController.h"

@interface TagsCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
