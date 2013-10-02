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
    NSArray *_ponyImages;
    NSInteger _index;
}

@end

@implementation DSPoniesRootViewController

- (void)changePonyImage
{
    _poniesView.image = [UIImage imageWithContentsOfFile:_ponyImages[_index]];
    NSString *notification = [NSString stringWithFormat:@"You get pony number: %d", _index];
    [[NSNotificationCenter defaultCenter] postNotificationName:CSBundlePostStatusUpdateNotification object:_bundle
                                                      userInfo:@{CSBundlePostStatusUpdateMessageKey: notification}];
    _index = (_index + 1) % _ponyImages.count;
}

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
    
    _ponyImages = [_bundle pathsForResourcesOfType:@".png" inDirectory:@"PonyImages"];
    _poniesView = [[UIImageView alloc] initWithImage:nil];
    [self changePonyImage];
    _poniesView.translatesAutoresizingMaskIntoConstraints = NO;
    _poniesView.hidden = YES;
    _poniesView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSDictionary *views = @{@"ponies": _poniesView};
    [self.view addSubview:_poniesView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ponies]|" options:kNilOptions metrics:Nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ponies]|" options:kNilOptions metrics:Nil views:views]];
    
    _poniesView.userInteractionEnabled = YES;
    UIButton *nextPony = [UIButton buttonWithType:UIButtonTypeCustom];
    nextPony.translatesAutoresizingMaskIntoConstraints = NO;
    //nextPony.backgroundColor = [UIColor redColor];
    [nextPony addTarget:self action:@selector(changePonyImage) forControlEvents:UIControlEventTouchUpInside];
    
    views = @{@"nextPony": nextPony};
    [_poniesView addSubview:nextPony];
    [_poniesView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nextPony]|" options:kNilOptions metrics:Nil views:views]];
    [_poniesView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nextPony]|" options:kNilOptions metrics:Nil views:views]];
    
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle;
}

- (void)beginPonies:(id)sender
{
    _poniesButton.hidden = YES;
    _poniesView.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:CSBundlePostStatusUpdateNotification object:_bundle
                                                      userInfo:@{CSBundlePostStatusUpdateMessageKey: @"You get the ponies!"}];
}


@end
