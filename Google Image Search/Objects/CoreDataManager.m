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

@synthesize managedObjectContext=_managedObjectContext;

+ (CoreDataManager *)sharedManager {
  static dispatch_once_t pred;
  static CoreDataManager *sharedManager = nil;
  
  dispatch_once(&pred, ^{
    sharedManager = [[CoreDataManager alloc] init];
  });
  return sharedManager;
}

- (id)init {
  if (self = [super init]) {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setManagedObjectContext:[ad managedObjectContext]];
  }
  return self;
}

- (void)saveSearch:(NSString *)queryString {
  
  // Check to see if this search already exists, if it does do not save
  NSArray *existingSearch = [self arrayOfSearchesMatchingQueryString:queryString];
  if ( [existingSearch count] > 0 ) {
    return;
  }
  
  ImageSearch *newSearch = [NSEntityDescription insertNewObjectForEntityForName:@"ImageSearch" inManagedObjectContext:_managedObjectContext];
  [newSearch setSearchQuery:[queryString lowercaseString]];
  
  AppDelegate *ad = [[UIApplication sharedApplication] delegate];
  [ad saveContext];
}

- (NSArray *)arrayOfSearchesMatchingQueryString:(NSString *)queryString {

  NSError *error = nil;
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageSearch" inManagedObjectContext:_managedObjectContext];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchQuery = %@", [queryString lowercaseString]];
  [fetchRequest setPredicate:predicate];
  
  [fetchRequest setEntity:entity];
  return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)clearSearchHistory {
  
  AppDelegate *ad = [[UIApplication sharedApplication] delegate];
  
  NSError *error = nil;
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageSearch" inManagedObjectContext:_managedObjectContext];
  
  [fetchRequest setEntity:entity];
  NSArray *searches = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  [searches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [_managedObjectContext deleteObject:obj];
  }];
  
  [ad saveContext];
  
}

@end
