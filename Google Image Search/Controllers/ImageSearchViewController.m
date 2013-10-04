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
#import "UIImageView+WebCache.h"

@interface ImageSearchViewController () {
  NSURL *_moreResultsURL;
  NSArray *_images;
  MBProgressHUD *_hud;
}

@end

@implementation ImageSearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  [ImageRequestManager imageRequestWithSearchQueryString:@"mass effect" success:^(NSDictionary *response) {
    _moreResultsURL = [NSURL URLWithString:[[[response objectForKey:@"responseData"] objectForKey:@"cursor"] objectForKey:@"moreResultsUrl"]];
    _images = [[response objectForKey:@"responseData"] objectForKey:@"results"];
    [_hud hide:YES];
    [[self tableView] reloadData];
  } failure:^(NSError *error) {
    NSLog(@"%@", error.localizedDescription);
    [_hud hide:YES];
  }];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *imageDict = [_images objectAtIndex:indexPath.row];
  UITableViewCell *cell = [[UITableViewCell alloc] init];
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
  [imageView setClipsToBounds:YES];
  [imageView setContentMode:UIViewContentModeScaleAspectFill];
  [imageView setImageWithURL:[imageDict objectForKey:@"url"]];
  [[cell contentView] addSubview:imageView];
  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50;
}

@end
