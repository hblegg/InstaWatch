//
//  IGFeedViewController.m
//  AppsPaper
//
//  Created by Hashim Shafique on 12/14/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "IGFeedViewController.h"
#import "IGCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramUser.h"
#import <QuartzCore/QuartzCore.h>
#import "InstagramComment.h"

@interface IGFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *IGCollectionView;
- (IBAction)onDismissScreen:(id)sender;
@end

@implementation IGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.IGCollectionView registerClass:[IGCollectionViewCell class] forCellWithReuseIdentifier:@"picture"];
}

-(void) viewDidAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.goToCellNumber inSection:0];
    
    [self.IGCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.mediaList count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"picture" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    NSURL * url = [[self.mediaList objectAtIndex:indexPath.row] lowResolutionImageURL];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"Empty.png"];
    
    __weak IGCollectionViewCell *weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.imageView.image = image;
                                       [weakCell setNeedsLayout];
                                       
                                   } failure:nil];

    InstagramMedia *media = [self.mediaList objectAtIndex:indexPath.row];
    cell.userNameLabel.text = [[media user] username];

    cell.captionTextView.text = [[media caption] text];
    cell.captionTextView.editable = NO;
    
    NSURL * url2 = [[media user] profilePictureURL];
    
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];

    [cell.userImageView setImageWithURLRequest:request2
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *reques2t, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.userImageView.image = image;
                                       weakCell.userImageView.layer.cornerRadius = 20.0f;
                                       weakCell.userImageView.layer.masksToBounds = YES;
                                       CGSize itemSize = CGSizeMake(40, 40);
                                       UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
                                       CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                                       [weakCell.userImageView.image drawInRect:imageRect];
                                       weakCell.userImageView.image = UIGraphicsGetImageFromCurrentImageContext();
                                       UIGraphicsEndImageContext();

                                       [weakCell setNeedsLayout];
                                       
                                   } failure:nil];

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"into select");
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"into deselect");
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width, 400);
}

- (IBAction)onDismissScreen:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
