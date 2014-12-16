//
//  IGTableViewController.h
//  AppsPaper
//
//  Created by Hashim Shafique on 12/15/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *mediaList;
@property (nonatomic) NSInteger goToCellNumber;

@end
