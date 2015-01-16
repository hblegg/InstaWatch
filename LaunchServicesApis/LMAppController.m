//
//  LMAppController.m
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "LMAppController.h"
#import "InstagramKit.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramMedia.h"
#import "InstagramUser.h"

@interface PrivateApi_LSApplicationWorkspace
- (NSArray*)allInstalledApplications;
- (bool)openApplicationWithBundleID:(id)arg1;
@end

@interface LMAppController()
@property (nonatomic, strong) InstagramPaginationInfo *currentPaginationInfo;
@end

#pragma mark -

@implementation LMAppController
{
  PrivateApi_LSApplicationWorkspace* _workspace;
  NSArray* _installedApplications;

}

-(NSMutableArray*)mediaArray
{
    if (!_mediaArray)
        _mediaArray = [[NSMutableArray alloc] init];
    return _mediaArray;
}

- (instancetype)init
{
	self = [super init];
	if(self != nil)
	{
		_workspace = [NSClassFromString(@"LSApplicationWorkspace") new];
	}
	
	return self;
}

- (NSArray*)readApplications
{
	NSArray* allInstalledApplications = [_workspace allInstalledApplications];
	NSMutableArray* applications = [NSMutableArray arrayWithCapacity:allInstalledApplications.count];
    //self.currentPaginationInfo.nextMaxId
    [[InstagramEngine sharedEngine] getSelfFeedWithCount:50 maxId:nil success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.currentPaginationInfo = paginationInfo;
        [self.mediaArray removeAllObjects];
        
        [self.mediaArray addObjectsFromArray:media];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"finshedLoading"
         object:self];

    } failure:^(NSError *error) {
        NSLog(@"Request Self Feed Failed");
    }];

   for (int i = 0; i <20; i++)
    {
        LMApp *app1 = [[LMApp alloc] init];
        app1.icon = [UIImage imageNamed:@"Empty.png"];
        [app1 setName:@""];
        [app1 setBundleIdentifier:@""];
        
        [applications addObject:app1];
    }

    return applications;
}

- (NSArray*)installedApplications
{
	if(nil == _installedApplications)
	{
		_installedApplications = [self readApplications];
	}
	
	return _installedApplications;
}

- (BOOL)openAppWithBundleIdentifier:(NSString *)bundleIdentifier
{
	return (BOOL)[_workspace openApplicationWithBundleID:bundleIdentifier];
}

+ (instancetype)sharedInstance
{
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

@end
