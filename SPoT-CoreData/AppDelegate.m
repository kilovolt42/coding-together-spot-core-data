//
//  AppDelegate.m
//  SPoT-CoreData
//
//  Created by Kyle Stevens on 9/16/13.
//  Copyright (c) 2013 Kyle Stevens. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	if (!self.managedObjectContext) [self useSPoTDocument];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)useSPoTDocument {
	NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	url = [url URLByAppendingPathComponent:@"SPoT Document"];
	UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
		[document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
			if (success) {
				self.managedObjectContext = document.managedObjectContext;
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
