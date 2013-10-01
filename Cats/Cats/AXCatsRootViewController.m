//
//  AXCatsRootViewController.m
//  Cats
//
//  Created by James Savage on 9/30/13.
//  Copyright (c) 2013 James Savage <axiixc@icloud.com>. All rights reserved.
//

#import "AXCatsRootViewController.h"

@interface AXCatsRootViewController () {
    UIButton *_catsButton;
    UIImageView *_catsView;
    
    NSBundle *_bundle;
}

@end

@implementation AXCatsRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _catsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _catsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _catsButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_catsButton setTitle:@"Tap for Cats" forState:UIControlStateNormal];
    [_catsButton addTarget:self action:@selector(beginCats:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_catsButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_catsButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_catsButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    UIImage *cats = [UIImage imageWithContentsOfFile:[_bundle pathForResource:@"cats" ofType:@"jpg"]];
    _catsView = [[UIImageView alloc] initWithImage:cats];
    _catsView.translatesAutoresizingMaskIntoConstraints = NO;
    _catsView.hidden = YES;
    _catsView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSDictionary *views = @{@"cats": _catsView};
    [self.view addSubview:_catsView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cats]|" options:kNilOptions metrics:Nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cats]|" options:kNilOptions metrics:Nil views:views]];
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle;
}

- (void)beginCats:(id)sender
{
    _catsButton.hidden = YES;
    _catsView.hidden = NO;
}

@end
