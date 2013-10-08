//
//  SavedSearchesViewController.h
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/7/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidSelectPreviousSearchBlock)(NSString *searchQuery);

@interface SavedSearchesViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (id)initWithSelectionBlock:(DidSelectPreviousSearchBlock)selectionBlock;

@end
