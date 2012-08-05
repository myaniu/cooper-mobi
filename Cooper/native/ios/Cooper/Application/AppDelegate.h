//
//  AppDelegate.h
//  Cooper
//
//  Created by sunleepy on 12-6-29.
//  Copyright (c) 2012年 codesharp. All rights reserved.
//

#import "MainViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
{  
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+(AppDelegate*)sharedAppDelegate;

@property (retain, nonatomic) MainViewController *mainViewController;
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (retain, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic, readonly) NSPersistentStoreCoordinator *persistantStoreCoordiantor;
@property (retain, nonatomic) NSTimer *timer;

@end
