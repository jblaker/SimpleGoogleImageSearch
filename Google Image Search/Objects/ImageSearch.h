//
//  ImageSearch.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/7/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageSearch : NSManagedObject

@property (nonatomic, retain) NSString * searchQuery;

@end
