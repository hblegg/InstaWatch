//
//  ViewController.m
//  WatchSpringboard
//
//  Created by Lucas Menge on 10/23/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "ViewController.h"

#import "LMViewControllerView.h"
#import "LMSpringboardItemView.h"
#import "LMSpringboardView.h"
#import "LoginViewController.h"
#import "LMAppController.h"
#import "IGTableViewController.h"
#import "ALRadialMenu.h"

@interface ViewController () <UIGestureRecognizerDelegate, ALRadialMenuDelegate>
@property(nonatomic, strong) UIToolbar *toolbar;
@end

@implementation ViewController

#pragma mark - Privates

- (LMViewControllerView*)customView
{
  return (LMViewControllerView*)self.view;
}

- (LMSpringboardView*)springboard
{
  return [(LMViewControllerView*)self.view springboard];
}

#pragma mark Notifications

- (void)LM_didBecomeActive
{
  if([self customView].isAppLaunched == NO)
  {
    [[self springboard] centerOnIndex:0 zoomScale:1 animated:NO];
    [[self springboard] doIntroAnimation];
    [self springboard].alpha = 1;
  }
}

- (void)LM_didEnterBackground
{
  if([self customView].isAppLaunched == NO)
    [self springboard].alpha = 0;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  if([self springboard].zoomScale < [self springboard].minimumZoomLevelToLaunchApp)
    return NO;
  return YES;
}

#pragma mark - Input

- (void)LM_respringTapped:(id)sender
{
  if([self customView].isAppLaunched == YES)
  {
     [[self customView] quitApp];
    [UIView animateWithDuration:0.3 animations:^{
      [self setNeedsStatusBarAppearanceUpdate];
    }];
  }
  else
  {
    LMSpringboardView* springboard = [self springboard];
    [UIView animateWithDuration:0.3 animations:^{
      springboard.alpha = 0;
    } completion:^(BOOL finished) {
      [springboard doIntroAnimation];
      springboard.alpha = 1;
    }];
  }
}

- (void)LM_iconTapped:(UITapGestureRecognizer*)sender
{
    LMSpringboardItemView *item = (LMSpringboardItemView*) [(UIGestureRecognizer *)sender view];
    
    NSLog(@"title is %@", item.label.text);
    
    /*UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    // [aFlowLayout setItemSize:CGSizeMake(200, 140)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    IGramCollectionViewController *ig = [[IGramCollectionViewController alloc] initWithCollectionViewLayout:aFlowLayout];
    ig.mediaList = [[NSArray alloc] initWithArray:[[LMAppController sharedInstance] mediaArray]];
    ig.goToCellNumber = [item.bundleIdentifier integerValue];
    [self presentViewController:ig animated:YES completion:nil];*/
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGFeed" bundle:nil];
    IGTableViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"igfeed"];
    myController.mediaList = [[NSArray alloc] initWithArray:[[LMAppController sharedInstance] mediaArray]];
    myController.goToCellNumber = [item.bundleIdentifier integerValue];
   
    [self.navigationController pushViewController:myController animated:YES];
//    [self presentViewController:myController animated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LM_didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LM_didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
  
  LMSpringboardView* springboard = [self springboard];
  [springboard centerOnIndex:0 zoomScale:springboard.zoomScale animated:NO];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    [self reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad
{
  [super viewDidLoad];
    self.didLogin = NO;
  [[self customView].respringButton addTarget:self action:@selector(LM_respringTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self springboard].alpha = 0;
  
  for(LMSpringboardItemView* item in [self springboard].itemViews)
  {
      NSLog(@"added tap recognizer");
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LM_iconTapped:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [item addGestureRecognizer:tap];
  }
    
/*    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(login)];

    UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];

    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:button1];
    [items addObject:button2];
    [self.toolbar setItems:items animated:NO];
    [self.view addSubview:self.toolbar];*/
    
    //create an instance of the radial menu and set ourselves as the delegate.
    self.socialMenu = [[ALRadialMenu alloc] init];
    self.socialMenu.delegate = self;

    self.button = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-60, 30, 30)];
    [self.button addTarget:self action:@selector(plusTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.button setBackgroundImage:[UIImage imageNamed:@"addthis500.png"]
                        forState:UIControlStateNormal];
    
    [self.view addSubview:self.button];
}

-(void) plusTapped:(id) sender
{
    [self.socialMenu buttonsWillAnimateFromButton:sender withFrame:self.button.frame inView:self.view];
}

-(void) login
{
    NSLog(@"logging in");
    LoginViewController *login = [[LoginViewController alloc] init];
    login.collectionViewController = self;
    [self.navigationController pushViewController:login animated:YES];
}

-(void) logout
{
    [[InstagramEngine sharedEngine] logout];
    NSLog(@"logging out");
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  if([self isViewLoaded] == YES && [self customView].isAppLaunched == YES)
    return UIStatusBarStyleDefault;
  else
    return UIStatusBarStyleLightContent;
}

-(void) reloadData
{
    if (!self.didLogin)
        return;
    
    NSLog(@"reloading data");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addCustomGestures)
                                                 name:@"displayReady"
                                               object:nil];

    [[self customView] reloadMedia];
    self.didLogin = NO;
}

-(void) addCustomGestures
{
    NSLog(@"add custom gestures");
    
    for(LMSpringboardItemView* item in [self springboard].itemViews)
    {
        NSLog(@"added tap recognizer");
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LM_iconTapped:)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        [item addGestureRecognizer:tap];
    }

}

#pragma mark - radial menu delegate methods
- (NSInteger) numberOfItemsInRadialMenu:(ALRadialMenu *)radialMenu {
    if (radialMenu == self.radialMenu) {
        return 9;
    } else if (radialMenu == self.socialMenu) {
        return 3;
    }
    
    return 0;
}


- (NSInteger) arcSizeForRadialMenu:(ALRadialMenu *)radialMenu {
    if (radialMenu == self.radialMenu) {
        return 360;
    } else if (radialMenu == self.socialMenu) {
        return -90;
    }
    
    return 0;
}


- (NSInteger) arcRadiusForRadialMenu:(ALRadialMenu *)radialMenu {
    if (radialMenu == self.radialMenu) {
        return 80;
    } else if (radialMenu == self.socialMenu) {
        return 80;
    }
    
    return 0;
}


- (ALRadialButton *) radialMenu:(ALRadialMenu *)radialMenu buttonForIndex:(NSInteger)index {
    ALRadialButton *button = [[ALRadialButton alloc] init];
    if (radialMenu == self.radialMenu) {
        if (index == 1) {
            [button setImage:[UIImage imageNamed:@"dribbble"] forState:UIControlStateNormal];
        } else if (index == 2) {
            [button setImage:[UIImage imageNamed:@"youtube"] forState:UIControlStateNormal];
        } else if (index == 3) {
            [button setImage:[UIImage imageNamed:@"vimeo"] forState:UIControlStateNormal];
        } else if (index == 4) {
            [button setImage:[UIImage imageNamed:@"pinterest"] forState:UIControlStateNormal];
        } else if (index == 5) {
            [button setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        } else if (index == 6) {
            [button setImage:[UIImage imageNamed:@"instagram500"] forState:UIControlStateNormal];
        } else if (index == 7) {
            [button setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
        } else if (index == 8) {
            [button setImage:[UIImage imageNamed:@"googleplus-revised"] forState:UIControlStateNormal];
        } else if (index == 9) {
            [button setImage:[UIImage imageNamed:@"facebook500"] forState:UIControlStateNormal];
        }
        
    } else if (radialMenu == self.socialMenu) {
        if (index == 1) {
            [button setImage:[UIImage imageNamed:@"Logout"] forState:UIControlStateNormal];
        } else if (index == 2) {
            [button setImage:[UIImage imageNamed:@"login_red_icon"] forState:UIControlStateNormal];
        } else if (index == 3) {
            [button setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        }
    }
    
    if (button.imageView.image) {
        return button;
    }
    
    return nil;
}


- (void) radialMenu:(ALRadialMenu *)radialMenu didSelectItemAtIndex:(NSInteger)index {
    if (radialMenu == self.radialMenu) {
        [self.radialMenu itemsWillDisapearIntoButton:self.button];
    } else if (radialMenu == self.socialMenu) {
        [self.socialMenu itemsWillDisapearIntoButton:self.socialButton];
        if (index == 1) {
            [self logout];
        } else if (index == 2) {
            [self login];
        } else if (index == 3) {
            [[self customView] reloadMedia];
        }
    }
    
}

- (float)buttonSizeForRadialMenu:(ALRadialMenu *)radialMenu
{
    return 50;
}

@end
