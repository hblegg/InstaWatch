//
//  LoginViewController.h
//  AppsPaper
//
//  Created by Hashim Shafique on 12/11/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
#import "ViewController.h"
@interface LoginViewController : UIViewController

@property (nonatomic, assign) IKLoginScope scope;
@property (nonatomic, weak) ViewController *collectionViewController;

@end
