//
//  LoginViewController.m
//  AppsPaper
//
//  Created by Hashim Shafique on 12/11/14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UIWebViewDelegate>
- (IBAction)onCancelLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *mWebView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mWebView.scrollView.bounces = NO;
    self.mWebView.contentMode = UIViewContentModeScaleAspectFit;
    self.mWebView.delegate = self;
    
    self.mWebView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
    
    self.scope = IKLoginScopeRelationships | IKLoginScopeComments | IKLoginScopeLikes;
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSString *scopeString = [InstagramEngine stringForScope:self.scope];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    [self.mWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCancelLogin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //webView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            self.collectionViewController.didLogin = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end
