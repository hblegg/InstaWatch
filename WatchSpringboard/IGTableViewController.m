//
//  IGTableViewController.m
//  AppsPaper
//
//  Created by Hashim Shafique on 12/15/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "IGTableViewController.h"
#import "InstagramMedia.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramUser.h"
#import <QuartzCore/QuartzCore.h>
#import "InstagramComment.h"
#import "InstagramEngine.h"
#import "CommentsTableViewController.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface IGTableViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) InstagramUser *selfUser;
@property (nonatomic, strong) NSMutableArray *likedMedia;
@property (nonatomic, strong) UIImageView *playButton;
@end

@implementation IGTableViewController

-(NSMutableArray*) likedMedia
{
    if (!_likedMedia)
        _likedMedia = [[NSMutableArray alloc] init];
    return _likedMedia;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.goToCellNumber inSection:0]
                     atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
        self.selfUser = userDetail;
    } failure:nil];
    
    [self refreshLikeList];

}

-(void) refreshLikeList
{
    [[InstagramEngine sharedEngine] getMediaLikedBySelfWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.likedMedia = [NSMutableArray arrayWithArray:media];
        [self.tableView reloadData];
    } failure:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.mediaList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 485;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    InstagramMedia *media = [self.mediaList objectAtIndex:indexPath.row];
    if (![media isVideo])
        cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
    
    if (![media isVideo])
    cell.backgroundColor = [UIColor whiteColor];
    
    NSURL * url = [media lowResolutionImageURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"Empty.png"];
    
    __weak UITableViewCell *weakCell = cell;
    
    UIImageView *iv = (UIImageView*)[cell viewWithTag:3];
    

    [iv setImageWithURLRequest:request
     placeholderImage:placeholderImage
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         UIImageView *imv = (UIImageView*)[weakCell viewWithTag:3];
     imv.image = image;
         UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellImageTapped:)];
         tapped.numberOfTapsRequired = 1;
         tapped.delegate = self;
         imv.userInteractionEnabled = YES;
         [imv addGestureRecognizer:tapped];

     [weakCell setNeedsLayout];
         if ([media isVideo])
         {
             _playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
             _playButton.center = imv.center;
             [imv addSubview:_playButton];
             [imv bringSubviewToFront:_playButton];


         }
         else
         {
             [[imv subviews]
              makeObjectsPerformSelector:@selector(removeFromSuperview)];
         }
     }
                       failure:nil];
    

    UILabel *name = (UILabel*)[cell viewWithTag:2];
    name.text = [[media user] username];
    name.textColor = [UIColor blueColor];

    UILabel *date = (UILabel*)[cell viewWithTag:5];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd yyyy"];

    NSString *theDate = [dateFormat stringFromDate:[[media caption] createdDate]];
    date.text = theDate;

    UITextView *caption = (UITextView*)[cell viewWithTag:4];
    NSMutableAttributedString * user = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[[media user] username]]];
    
    [user addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, user.length)];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[[media caption] text]]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, string.length)];
    [user appendAttributedString:[[NSMutableAttributedString alloc]initWithString:@" "]];
    if ([[[media caption] text] length])
        [user appendAttributedString:string];
    caption.attributedText = user;

    caption.editable = NO;
    
    NSURL * url2 = [[media user] profilePictureURL];
    
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
    UIImageView *profile = (UIImageView*)[cell viewWithTag:1];
      [profile setImageWithURLRequest:request2
     placeholderImage:placeholderImage
     success:^(NSURLRequest *reques2t, NSHTTPURLResponse *response, UIImage *image) {
         UIImageView *prof = (UIImageView*)[weakCell viewWithTag:1];
     prof.image = image;
     prof.layer.cornerRadius = 20.0f;
     prof.layer.masksToBounds = YES;
     CGSize itemSize = CGSizeMake(40, 40);
     UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
     CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
     [prof.image drawInRect:imageRect];
     prof.image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     [weakCell setNeedsLayout];
     
     } failure:nil];
    
    UIButton *likeButton = (UIButton*)[cell viewWithTag:50];
    UIButton *commentButton = (UIButton*)[cell viewWithTag:51];
    
    [likeButton addTarget:self action:@selector(likeTapped:) forControlEvents:UIControlEventTouchUpInside];

    [commentButton addTarget:self action:@selector(commentTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self didLikeMedia:media])
    {
        NSLog(@"did like media");
        likeButton.titleLabel.textColor = [UIColor redColor];
    }
    else
        likeButton.titleLabel.textColor = [UIColor grayColor];
    return cell;
}

-(void) likeTapped:(id) sender
{
    UITableViewCell *clickedCell = (UITableViewCell*)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    NSLog(@"indexPath = %ld", (long)clickedButtonPath.row);
    InstagramMedia *media = self.mediaList[clickedButtonPath.row];
    NSString *id = [media Id];
    if (![self didLikeMedia:media])
    {
        [[InstagramEngine sharedEngine] likeMedia:id withSuccess:nil failure:nil];
        [[InstagramEngine sharedEngine] likeMedia:id withSuccess:^{
            NSLog(@"like worked");
            [self refreshLikeList];
        } failure:^(NSError *error) {
            NSLog(@"like failed");
        }];
    }
    else
    {
        [[InstagramEngine sharedEngine] unlikeMedia:id withSuccess:^{
            [self refreshLikeList];
        } failure:nil];
    }
}

-(void) commentTapped:(id) sender
{
    UITableViewCell *clickedCell = (UITableViewCell*)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    NSLog(@"indexPath = %ld", (long)clickedButtonPath.row);
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CommentsTableViewController *dest = (CommentsTableViewController*)[segue destinationViewController];
    UITableViewCell *clickedCell = (UITableViewCell*)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];

    [dest setMedia:self.mediaList[clickedButtonPath.row]];
    
}

-(BOOL) didLikeMedia:(InstagramMedia*) media
{
    for (InstagramMedia *likedMedia in self.likedMedia)
    {
        if ([likedMedia.Id isEqualToString:media.Id])
            return YES;
    }

    return NO;
}

-(void)cellImageTapped:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:self.tableView];
    
    NSIndexPath *theIndexPath = [self.tableView indexPathForRowAtPoint:point];
    InstagramMedia *media = [self.mediaList objectAtIndex:theIndexPath.row];
    if (![media isVideo])
    {
    NSLog(@"index path is %@", theIndexPath);
    
    UITableViewCell *clickedCell = [self.tableView cellForRowAtIndexPath:theIndexPath];
    
    UIImageView *iv = (UIImageView*)[clickedCell viewWithTag:3];
    
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = iv.image;
    imageInfo.referenceRect = iv.frame;
    imageInfo.referenceView = iv.superview;
    imageInfo.referenceContentMode = iv.contentMode;
    imageInfo.referenceCornerRadius = iv.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
    else
    {
        MPMoviePlayerViewController *videoPlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[media lowResolutionVideoURL]];
        videoPlayerView.moviePlayer.fullscreen=FALSE;
        
        [self presentMoviePlayerViewControllerAnimated:videoPlayerView];
        [videoPlayerView.moviePlayer play];

        
    }

}
@end
