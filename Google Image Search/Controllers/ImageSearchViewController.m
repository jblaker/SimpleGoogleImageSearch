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
#import "ThreeImageCell.h"

#define kThreeImageCellIdentifier @"ThreeImageCell"

@interface ImageSearchViewController () {
  NSArray *_pages;
  NSMutableArray *_images;
  MBProgressHUD *_hud;
  NSMutableArray *_imageSets;
  ImageRequestManager *_imageRequestManager;
  int _currentPageIndex;
  int _imageCount;
  BOOL _isRequestinImages;
}

@end

@implementation ImageSearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _imageSets = [[NSMutableArray alloc] init];
  
  // Register the nib for the table cells
  [self.tableView registerNib:[UINib nibWithNibName:@"ThreeImageCell" bundle:nil] forCellReuseIdentifier:kThreeImageCellIdentifier];
  
  // Show the loading view
  _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
  // Initiate the request
  _imageRequestManager = [ImageRequestManager imageRequestWithSearchQueryString:@"pandas" success:^(NSDictionary *response) {
    
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
        _imageCount = [_images count];
        [_hud hide:YES];
        [self buildImageSets];
        [[self tableView] reloadData];
        
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
  if(y > h + reload_distance && _isRequestinImages == NO) {
    [self requestMoreImages];
  }
}

#pragma mark - Helper Methods

- (void)requestMoreImages {
  _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
  _isRequestinImages = YES;
  
  int startAt = [[[_pages objectAtIndex:_currentPageIndex+1] objectForKey:@"start"] intValue];
  
  [_imageRequestManager fetchMoreImageResultsStartingAt:startAt success:^(NSDictionary *response) {
    
    [_images addObjectsFromArray:[[response objectForKey:@"responseData"] objectForKey:@"results"]];
    _imageCount += [_images count];
    [_hud hide:YES];
    [self buildImageSets];
    [[self tableView] reloadData];
    _isRequestinImages = NO;
    
  } failure:^(NSError *error) {
    NSLog(@"%@", error.localizedDescription);
    [_hud hide:YES];
    _isRequestinImages = NO;
  }];
  
}

- (void)buildImageSets {
  for (int i=0; i <= ceilf(_imageCount / 3.0f); i++) {
    NSRange threeImageRange = _images.count >= 3 ? NSMakeRange(0, 3) : NSMakeRange(0, _images.count);
    NSArray *threeImages = [_images objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:threeImageRange]];
    [_images removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:threeImageRange]];
    [_imageSets addObject:threeImages];
  }
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch(section) {
    case 0:
      return ceilf(_imageCount / 3.0f);
    case 1:
      return 1;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case 0:
      return [self threeImageCellForIndexPath:indexPath];
    case 1:
      return [self fetchNewImagesCell];
  }
  return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2; // First section is for images second second is for cell that activates to fetch new images
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 100;
}

#pragma mark - Table View Cells

- (ThreeImageCell *)threeImageCellForIndexPath:(NSIndexPath *)indexPath {
  ThreeImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kThreeImageCellIdentifier forIndexPath:indexPath];
  [cell setImageDicts:[_imageSets objectAtIndex:indexPath.row]];
  [cell loadImages];
  return cell;
}

- (UITableViewCell *)fetchNewImagesCell {
  UITableViewCell *cell = [[UITableViewCell alloc] init];
  [[cell contentView] setBackgroundColor:[UIColor redColor]];
  return cell;
}

@end
