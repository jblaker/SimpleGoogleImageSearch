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

#define kThreeImageCellIdentifier @"ThreeImageCell"

@interface ImageSearchViewController () {
  NSArray *_pages;
  NSMutableArray *_images;
  MBProgressHUD *_hud;
  ImageRequestManager *_imageRequestManager;
  int _currentPageIndex;
  BOOL _isRequestinImages;
}

@end

@implementation ImageSearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self buildBarButtonItems];
  
  [[self collectionView] setBackgroundColor:[UIColor whiteColor]];
  
  // Register the nib for the table cells
  [[self collectionView] registerClass:[ImageCell class] forCellWithReuseIdentifier:kThreeImageCellIdentifier];
  
  [self doSearch:nil];
  
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
  
  float reload_distance = 10;
  if(y > h + reload_distance && _images.count > 1 && _isRequestinImages == NO) {
    [self requestMoreImages];
  }
}

#pragma mark - Helper Methods

- (void)buildBarButtonItems {
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(doSearch:)];
  [[self navigationItem] setRightBarButtonItem:searchButton];
}

- (void)doSearch:(id)sender  {
  UIAlertView *searchAlert = [[UIAlertView alloc] initWithTitle:@"New Search" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
  [searchAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
  [searchAlert show];
}

- (void)requestMoreImages {
  NSLog(@"%i total images", _images.count);
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
  _imageRequestManager = [ImageRequestManager imageRequestWithSearchQueryString:queryString success:^(NSDictionary *response) {
    
    _pages = [[[response objectForKey:@"responseData"] objectForKey:@"cursor"] objectForKey:@"pages"];
    _images = [NSMutableArray arrayWithArray:[[response objectForKey:@"responseData"] objectForKey:@"results"]];
    
    // Because the API only allows for a maxiumum of 8 images at a time to be returned we need to do additional requests
    int startAt = [[[_pages objectAtIndex:1] objectForKey:@"start"] intValue];
    
    [_imageRequestManager fetchMoreImageResultsStartingAt:startAt success:^(NSDictionary *response) {
      
      int startAt = [[[_pages objectAtIndex:2] objectForKey:@"start"] intValue];
      _currentPageIndex = 2;
      [_images addObjectsFromArray:[[response objectForKey:@"responseData"] objectForKey:@"results"]];
      
      [_imageRequestManager fetchMoreImageResultsStartingAt:startAt success:^(NSDictionary *response) {
        
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
    
  } failure:^(NSError *error) {
    
    NSLog(@"%@", error.localizedDescription);
    [_hud hide:YES];
    
  }];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    [self doSearchWithString:[[alertView textFieldAtIndex:0] text]];
  }
}

#pragma mark - Table View Data Source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
  return _images.count;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kThreeImageCellIdentifier forIndexPath:indexPath];
  [cell loadImage:[_images objectAtIndex:indexPath.row]];
  return cell;
}

@end
