//
//  CommentsTableViewController.m
//  AppsPaper
//
//  Created by Hashim Shafique on 1/9/15.
//  Copyright (c) 2015 Lucas Menge. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "InstagramComment.h"
#import "InstagramUser.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramEngine.h"

@interface CommentsTableViewController () <UITextFieldDelegate>
- (IBAction)onSendButtonTouched:(id)sender;
@end

@implementation CommentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.media comments] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"comments" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        UIImage *placeholderImage = [UIImage imageNamed:@"Empty.png"];
        
        InstagramComment *comment =self.media.comments[indexPath.row];
        UILabel *username = (UILabel*)[cell viewWithTag:1];
        InstagramUser *user = [comment user];
        username.text = [user username];
        
        UITextView *com = (UITextView*)[cell viewWithTag:2];
        com.text = [comment text];
        
        NSURL * url2 = [user profilePictureURL];
        
        NSURLRequest *request2 = [NSURLRequest requestWithURL:url2];
        UIImageView *profile = (UIImageView*)[cell viewWithTag:3];
        __weak UITableViewCell *weakCell = cell;

        [profile setImageWithURLRequest:request2
                       placeholderImage:placeholderImage
                                success:^(NSURLRequest *reques2t, NSHTTPURLResponse *response, UIImage *image) {
                                    UIImageView *prof = (UIImageView*)[weakCell viewWithTag:3];
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
    }
    return cell;
}


- (IBAction)onSendButtonTouched:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell*)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    NSLog(@"indexPath = %ld", (long)clickedButtonPath.row);
    UITextField *tv = (UITextField*)[clickedCell viewWithTag:15];
    [tv resignFirstResponder];
    
    [[InstagramEngine sharedEngine] createComment:tv.text onMedia:self.media.Id withSuccess:^{
        [self.tableView reloadData];
        int sectionNumber = 1;
        NSInteger rowNumber = [[self.media comments] count];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } failure:^(NSError *error){
        NSLog(@"failed to send comment %@", error);
    }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"did begin editing");
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

// if we encounter a newline character return
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // enter closes the keyboard
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
