//
//  PhotosCDTVC.h
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/17/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//
//  Can do "setImageURL:" segue and will call said method in destincation view controller.

#import "PhotosCDTVC.h"
#import "Tag.h"

@interface PhotosByTagCDTVC : PhotosCDTVC

@property (nonatomic, strong) Tag *tag;

@end
