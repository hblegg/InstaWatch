//
//  LMApp.h
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMApp : NSObject

@property (nonatomic, strong) NSString* bundleIdentifier;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) UIImage* icon;

@property (nonatomic, readonly) BOOL isHiddenApp;

+ (instancetype)appWithPrivateProxy:(id)privateProxy;
+ (instancetype)appWithBundleIdentifier:(NSString*)bundleIdentifier;

@end
