//
//  ImageSearchViewController.m
//  Google Image Search
//
//  Created by Jeremy Blaker on 10/4/13.
//  Copyright (c) 2013 blakerdesign. All rights reserved.
//

#import "ImageSearchViewController.h"
#import "ImageRequestManager.h"
#import "MBProgressHUD.h"
#import "ImageCell.h"
#import "SavedSearchesViewController.h"

#define kThreeImageCellIdentifier @"ThreeImageCell"

typedef enum {
  SearchQueryTextField
}TextFields;

@interface ImageSearchViewController () {
  NSArray *_pages;
  NSMutableArray *_images;
  MBProgressHUD *_hud;
  int _currentPageIndex;
  BOOL _isRequestinImages;
  UITextField *_searchQueryTextField;
  UIAlertView *_searchQueryAlertView;
  BOOL _hasShownAutoPopup;
}

@end

@implementation ImageSearchViewController

@synthesize imageRequestManager=_imageRequestManager;

- (id)initWithCollectionViewLayout:(PSTCollectionViewLayout *)layout {
  if (self = [super initWithCollectionViewLayout:layout]) {
    [self setTitle:@"Image Search"];
    
    _imageRequestManager = [[ImageRequestManager alloc] init];
    
    [self buildBarButtonItems];
    
    [[self collectionView] setBackgroundColor:[UIColor whiteColor]];
    
    // Register the nib for the table cells
    [[self collectionView] registerClass:[ImageCell class] forCellWithReuseIdentifier:kThreeImageCellIdentifier];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[[self navigationController] navigationBar] setTintColor:[UIColor darkGrayColor]];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (_hasShownAutoPopup == NO) {
    [self doSearch:nil];
    _hasShownAutoPopup = YES;
  }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
  CGPoint offset = aScrollView.contentOffset;
  CGRect bounds = aScrollView.bounds;
  CGSize size = aScrollView.contentSize;
  UIEdgeInsets inset = aScrollView.contentInset;
  float y = offset.y + bounds.size.height - inset.bottom;
  float h = size.height;
  // NSLog(@"offset: %f", offset.y);
  // NSLog(@"content.height: %f", size.height);
  // NSLog(@"bounds.height: %f", bounds.size.height);
  // NSLog(@"inset.top: %f", inset.top);
  // NSLog(@"inset.bottom: %f", inset.bottom);
  // NSLog(@"pos: %f of %f", y, h);
  
  float reload_distance = 0;
  if(y > h + reload_distance && _images.count > 1 && _isRequestinImages == NO) {
    [self requestMoreImages];
  }
}

#pragma mark - Helper Methods

- (void)buildBarButtonItems {
  
  UIBarButtonItem *previousSearchButton = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(showPreviousSearches:)];
  
  [[self navigationItem] setLeftBarButtonItem:previousSearchButton];
  
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(doSearch:)];
  [[self navigationItem] setRightBarButtonItem:searchButton];
}

- (void)doSearch:(id)sender  {
  _searchQueryAlertView = [[UIAlertView alloc] initWithTitle:@"New Search" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
  [_searchQueryAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
  _searchQueryTextField = [_searchQueryAlertView textFieldAtIndex:0];
  [_searchQueryTextField setDelegate:self];
  [_searchQueryTextField setTag:SearchQueryTextField];
  [_searchQueryAlertView show];
}

- (void)showPreviousSearches:(id)sender {
  SavedSearchesViewController *savedSearchesVC = [[SavedSearchesViewController alloc] initWithSelectionBlock:^(NSString *searchQuery) {
    [self doSearchWithString:searchQuery];
  }];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:savedSearchesVC];
  [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
  [self presentViewController:navController animated:YES completion:nil];
}

- (void)requestMoreImages {
  if ( _currentPageIndex < _pages.count-1) {
  
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelText:@"Searching..."];
    
    _isRequestinImages = YES;
    
    _currentPageIndex++;

    int startAt = [[[_pages objectAtIndex:_currentPageIndex] objectForKey:@"start"] intValue];
    
    [_imageRequestManager fetchMoreImageResultsStartingAt:startAt success:^(NSDictionary *response) {
      
      [_images addObjectsFromArray:[[response objectForKey:@"responseData"] objectForKey:@"results"]];
      [[self collectionView] reloadData];

      [_hud hide:YES];
      _isRequestinImages = NO;
      
    } failure:^(NSError *error) {
      NSLog(@"%@", error.localizedDescription);
      [_hud hide:YES];
      _isRequestinImages = NO;
    }];
  
  }
  
}

- (void)doSearchWithString:(NSString *)queryString {
  
  _isRequestinImages = YES;
  
  // Show the loading view
  _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  [_hud setLabelText:@"Searching..."];
  
  // Initiate the request
  [_imageRequestManager imageRequestWithSearchQueryString:queryString success:^(NSDictionary *response) {
    
    _pages = [[[response objectForKey:@"responseData"] objectForKey:@"cursor"] objectForKey:@"pages"];
    _images = [NSMutableArray arrayWithArray:[[response objectForKey:@"responseData"] objectForKey:@"results"]];
    
    // Because the API only allows for a maxiumum of 8 images at a time to be returned we need to do additional requests
    int startAt = [[[_pages objectAtIndex:1] objectForKey:@"start"] intValue];
    
    [_imageRequestManager fetchMoreImageResultsStartingAt:startAt success:^(NSDictionary *response) {
      
      _currentPageIndex = 2;
      [_images addObjectsFromArray:[[response objectForKey:@"responseData"] objectForKey:@"results"]];
      
      [_hud hide:YES];
      [[self collectionView] reloadData];
      _isRequestinImages = NO;
      
    } failure:^(NSError *error) {
      NSLog(@"%@", error.localizedDescription);
      [_hud hide:YES];
    }];
    
  } failure:^(NSError *error) {
    
    NSLog(@"%@", error.localizedDescription);
    [_hud hide:YES];
    
  }];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([textField tag] == SearchQueryTextField) {
    [self doSearchWithString:[_searchQueryTextField text]];
    [_searchQueryAlertView dismissWithClickedButtonIndex:1 animated:YES];
    return NO;
  }
  return YES;
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch(buttonIndex) {
    case 1:
      [self doSearchWithString:[[alertView textFieldAtIndex:0] text]];
      break;
    default:
      _isRequestinImages = YES;
  }
}

#pragma mark - Table View Data Source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
  return _images.count;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kThreeImageCellIdentifier forIndexPath:indexPath];
  [cell loadImage:[_images objectAtIndex:indexPath.item]];
  return cell;
}

@end
