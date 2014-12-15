//
//  IGCollectionViewCell.m
//  AppsPaper
//
//  Created by Hashim Shafique on 12/14/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "IGCollectionViewCell.h"

@implementation IGCollectionViewCell

- (void)awakeFromNib
{
    // Initialization code
    NSLog(@"hello");
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"IGCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) { return nil; }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
        
        self = [arrayOfViews objectAtIndex:0];
        
        //CGFloat cellSize = self.contentView.bounds.size.width;
        //self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, cellSize, cellSize)];
        [self.imageView setClipsToBounds:YES];
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.captionLabel.numberOfLines = 0;
    }
    return self;
}

@end
