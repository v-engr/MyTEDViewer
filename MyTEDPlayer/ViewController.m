//
//  ViewController.m
//  MyTEDPlayer
//
//  Created by Ben G on 25.04.15.
//  Copyright (c) 2015 beng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // запрос
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.link];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
