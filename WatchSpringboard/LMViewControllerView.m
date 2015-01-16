//
//  LMViewControllerView.m
//  WatchSpringboard
//
//  Created by Lucas Menge on 10/24/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "LMViewControllerView.h"

#import "LMSpringboardItemView.h"
#import "LMSpringboardView.h"
#import "InstagramMedia.h"
#import "UIImageView+AFNetworking.h"
#import "LMAppController.h"
#import "InstagramComment.h"

@interface LMViewControllerView ()
{
  __strong UIImageView* _appLaunchMaskView;
  LMSpringboardItemView* _lastLaunchedItem;
}

@end

@implementation LMViewControllerView


- (void)launchAppItem:(LMSpringboardItemView*)item
{

}

- (void)quitApp
{
  if(_isAppLaunched == YES)
  {
    _isAppLaunched = NO;
    
    CGPoint pointInSelf = [self convertPoint:_lastLaunchedItem.icon.center fromView:_lastLaunchedItem];
    CGFloat dx = pointInSelf.x-_appView.center.x;
    CGFloat dy = pointInSelf.y-_appView.center.y;
    
    double appScale = 120*_lastLaunchedItem.scale/MIN(_appView.bounds.size.width,_appView.bounds.size.height);
    CGAffineTransform appTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), appScale, appScale);
    _appView.maskView = _appLaunchMaskView;
    
    double springboardScale = MIN(self.bounds.size.width,self.bounds.size.height)/(120*_lastLaunchedItem.scale);
    _springboard.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(springboardScale,springboardScale), -dx, -dy);
    _springboard.alpha = 0;
    
    double maskScale = MAX(self.bounds.size.width,self.bounds.size.height)/(120*_lastLaunchedItem.scale)*1.2*_lastLaunchedItem.scale;
    
    _appLaunchMaskView.transform = CGAffineTransformMakeScale(maskScale,maskScale);
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      _appView.alpha = 1;
      _appView.transform = appTransform;
      
      _appLaunchMaskView.transform = CGAffineTransformMakeScale(0.01, 0.01);
      
      _springboard.alpha = 1;
      _springboard.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      _appView.alpha = 0;
      _appView.maskView = nil;
    }];
    
    _lastLaunchedItem = nil;
  }
}

#pragma mark - UIView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if(self)
  {
    CGRect fullFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImageView* bg = [[UIImageView alloc] initWithFrame:fullFrame];
    bg.image = [UIImage imageNamed:@"Wallpaper.png"];
    bg.contentMode = UIViewContentModeScaleAspectFill;
    bg.autoresizingMask = mask;
    [self addSubview:bg];
    
    _springboard = [[LMSpringboardView alloc] initWithFrame:fullFrame];
    _springboard.autoresizingMask = mask;
    
    NSMutableArray* itemViews = [NSMutableArray array];
	  
	  NSArray* apps = [LMAppController sharedInstance].installedApplications;
	  
    // pre-render the known icons
    NSMutableArray* images = [NSMutableArray array];
    UIBezierPath* clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(0, 0, 120, 120), 0.5,0.5)];
    for(LMApp* app in apps)
    {
      UIImage* image = app.icon;
      
      UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, [UIScreen mainScreen].scale);
      [clipPath addClip];
      [image drawInRect:CGRectMake(0, 0, 120, 120)];
      UIImage* renderedImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      [images addObject:renderedImage];
    }
    
    // build out item set
    NSInteger index = 0;
    for(LMApp* app in apps)
    {
      LMSpringboardItemView* item = [[LMSpringboardItemView alloc] init];
      item.bundleIdentifier = app.bundleIdentifier;
      [item setTitle:app.name];
      item.icon.image = images[index++];
      [itemViews addObject:item];
    }
    _springboard.itemViews = itemViews;
    
    [self addSubview:_springboard];
    
    _appView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"App.png"]];
    _appView.transform = CGAffineTransformMakeScale(0, 0);
    _appView.alpha = 0;
    _appView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_appView];
    
    _appLaunchMaskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    
    _respringButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_respringButton];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect statusFrame = {0};
  if(self.window != nil)
  {
    CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
    statusFrame = [self.window convertRect:statusFrame toView:self];
    
    UIEdgeInsets insets = _springboard.contentInset;
    insets.top = statusFrame.size.height;
    _springboard.contentInset = insets;
  }
  
  CGSize size = self.bounds.size;
  
  _appView.bounds = CGRectMake(0, 0, size.width, size.height);
  _appView.center = CGPointMake(size.width*0.5, size.height*0.5);
  
  _appLaunchMaskView.center  =CGPointMake(size.width*0.5, size.height*0.5+statusFrame.size.height);
  
  _respringButton.bounds = CGRectMake(0, 0, 120, 120);
  _respringButton.center = CGPointMake(size.width*0.5, size.height-120*0.5);
}

- (void)reloadMedia
{
    NSLog(@"ready to reload media");
    
    self.activtyView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:self.activtyView];
    self.activtyView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self.activtyView startAnimating];

    [[LMAppController sharedInstance] readApplications];
    self.springboard.itemViews = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateImages)
                                                 name:@"finshedLoading"
                                               object:nil];

}

-(void) updateImages
{
    NSLog(@"updating images...");
    NSMutableArray* itemViews = [NSMutableArray array];
    
    // pre-render the known icons
    NSMutableArray* images = [NSMutableArray array];
    UIBezierPath* clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(0, 0, 120, 120), 0.5,0.5)];
    
    for(InstagramMedia* app in [[LMAppController sharedInstance] mediaArray])
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:app.thumbnailURL]];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, [UIScreen mainScreen].scale);
        [clipPath addClip];
        [image drawInRect:CGRectMake(0, 0, 120, 120)];
        UIImage* renderedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [images addObject:renderedImage];
    }

    // build out item set
    NSInteger index = 0;
    for(InstagramMedia* app in [[LMAppController sharedInstance] mediaArray])
    {
        LMSpringboardItemView* item = [[LMSpringboardItemView alloc] init];
        item.bundleIdentifier = @"";
        [item setTitle:[app.caption text]];
        item.bundleIdentifier = [NSString stringWithFormat:@"%ld", (long)index];
        item.icon.image = images[index++];
        [itemViews addObject:item];
    }

    _springboard.itemViews = itemViews;
    
    _appView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"App.png"]];
    _appView.transform = CGAffineTransformMakeScale(0, 0);
    _appView.alpha = 0;
    _appView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_appView];
    
    _appLaunchMaskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    
    _respringButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.activtyView stopAnimating];
    self.activtyView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"displayReady"
     object:self];

}

@end
