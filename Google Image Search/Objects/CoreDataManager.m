//
//  CoreDataManager.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/7/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "ImageSearch.h"

@implementation CoreDataManager

+ (CoreDataManager *)sharedManager {
  static dispatch_once_t pred;
  static CoreDataManager *sharedManager = nil;
  
  dispatch_once(&pred, ^{
    sharedManager = [[CoreDataManager alloc] init];
  });
  return sharedManager;
}

- (void)saveSearch:(NSString *)queryString {
  
  // Check to see if this search already exists, if it does do not save
  NSArray *existingSearch = [self arrayOfSearchesMatchingQueryString:queryString];
  if ( [existingSearch count] > 0 ) {
    return;
  }
  
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *moc = [ad managedObjectContext];
  ImageSearch *newSearch = [NSEntityDescription insertNewObjectForEntityForName:@"ImageSearch" inManagedObjectContext:moc];
  [newSearch setSearchQuery:[queryString lowercaseString]];
  NSError *error;
  if (![ad.managedObjectContext save:&error]) {
    NSLog(@"Error Saving: %@", [error localizedDescription]);
  }
}

- (NSArray *)arrayOfSearchesMatchingQueryString:(NSString *)queryString {
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];

  NSError *error = nil;
  NSManagedObjectContext *context = [ad managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageSearch" inManagedObjectContext:context];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchQuery = %@", [queryString lowercaseString]];
  [fetchRequest setPredicate:predicate];
  
  [fetchRequest setEntity:entity];
  return [context executeFetchRequest:fetchRequest error:&error];
}

@end
