//
//  SavedSearchesViewController.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/7/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "SavedSearchesViewController.h"
#import "AppDelegate.h"
#import "ImageSearch.h"

@interface SavedSearchesViewController () {
  DidSelectPreviousSearchBlock _selectionBlock;
}

@end

@implementation SavedSearchesViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (id)initWithSelectionBlock:(DidSelectPreviousSearchBlock)selectionBlock {
  if (self = [super initWithStyle:UITableViewStylePlain]) {
    _selectionBlock = selectionBlock;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setTitle:@"Search History"];
  [self buildBarButtonItems];
}

- (void)buildBarButtonItems {
  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissSelf:)];
  [[self navigationItem] setRightBarButtonItem:closeButton];
}

- (void)dismissSelf:(id)sender {
  [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (NSFetchedResultsController *)fetchedResultsController {
  
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *moc = [ad managedObjectContext];
  
  if (moc == nil) {
    return nil;
  }
  
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageSearch" inManagedObjectContext:moc];
  [fetchRequest setEntity:entity];
  
  NSSortDescriptor *searchQuerySort = [[NSSortDescriptor alloc] initWithKey:@"searchQuery" ascending:YES];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:searchQuerySort, nil]];
  
  [fetchRequest setFetchBatchSize:20];
  
  NSFetchedResultsController *theFetchedResultsController =
  [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
  
  self.fetchedResultsController = theFetchedResultsController;
  _fetchedResultsController.delegate = self;
  
  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }

  return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  ImageSearch *search = [[self fetchedResultsController] objectAtIndexPath:indexPath];
  
  [[cell textLabel] setText:[search searchQuery]];
  
  [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  ImageSearch *search = [[self fetchedResultsController] objectAtIndexPath:indexPath];
  if( _selectionBlock ) {
    _selectionBlock([search searchQuery]);
  }
  [self dismissSelf:nil];
}

- (void)reloadFetchedResults:(NSNotification*)note {
  
  // Refetch the data
  self.fetchedResultsController = nil;
  [self fetchedResultsController];
  [self.tableView reloadData];
  
}

@end
