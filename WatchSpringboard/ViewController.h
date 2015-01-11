//
//  ViewController.h
//  WatchSpringboard
//
//  Created by Lucas Menge on 10/23/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"

@interface ViewController : UIViewController

-(void) reloadData;
@property(nonatomic) BOOL didLogin;
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@property (strong, nonatomic) ALRadialMenu *socialMenu;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *socialButton;

@end

