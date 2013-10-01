//
//  DSPoniesRootViewController.m
//  Ponies
//
//  Created by David Savrda on 9/30/13.
//  Copyright (c) 2013 David Savrda. All rights reserved.
//

#import "DSPoniesRootViewController.h"

@interface DSPoniesRootViewController (){
    UIButton *_poniesButton;
    UIImageView *_poniesView;
    
    NSBundle *_bundle;
}

@end

@implementation DSPoniesRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _poniesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _poniesButton.translatesAutoresizingMaskIntoConstraints = NO;
    _poniesButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_poniesButton setTitle:@"Tap for Ponies" forState:UIControlStateNormal];
    [_poniesButton addTarget:self action:@selector(beginPonies:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_poniesButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_poniesButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_poniesButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    UIImage *cats = [UIImage imageWithContentsOfFile:[_bundle pathForResource:@"cats" ofType:@"jpg"]];
    _poniesView = [[UIImageView alloc] initWithImage:cats];
    _poniesView.translatesAutoresizingMaskIntoConstraints = NO;
    _poniesView.hidden = YES;
    _poniesView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSDictionary *views = @{@"cats": _poniesView};
    [self.view addSubview:_poniesView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cats]|" options:kNilOptions metrics:Nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cats]|" options:kNilOptions metrics:Nil views:views]];
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle;
}

- (void)beginPonies:(id)sender
{
    _poniesButton.hidden = YES;
    _poniesView.hidden = NO;
}


@end
