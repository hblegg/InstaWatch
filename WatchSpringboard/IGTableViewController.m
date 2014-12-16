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

@interface IGTableViewController ()

@end

@implementation IGTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.goToCellNumber inSection:0]
                     atScrollPosition:UITableViewScrollPositionMiddle animated:YES];}

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    InstagramMedia *media = [self.mediaList objectAtIndex:indexPath.row];
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
     [weakCell setNeedsLayout];
     
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
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

@end
