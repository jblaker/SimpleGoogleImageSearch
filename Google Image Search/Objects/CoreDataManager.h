//
//  CoreDataManager.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/7/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)sharedManager;
- (void)saveSearch:(NSString *)queryString;
- (void)clearSearchHistory;

@end
