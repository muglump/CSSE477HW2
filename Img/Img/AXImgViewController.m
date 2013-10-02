//
//  AXImgViewController.m
//  Img
//
//  Created by James Savage on 10/1/13.
//  Copyright (c) 2013 James Savage <axiixc@icloud.com>. All rights reserved.
//

#import "AXImgViewController.h"

@interface AXImgViewController_Private : UIViewController <CSBundle, UITextFieldDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    NSBundle *_bundle;
    
    UITextField *_textField;
    UIImageView *_imageView;
    UIProgressView *_progressView;
    
    NSURLSession *_session;
    NSURLSessionDownloadTask *_downloadTask;
}

@end

@implementation AXImgViewController {
    AXImgViewController_Private *_private;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        _private = [[AXImgViewController_Private alloc] init];
        [self pushViewController:_private animated:NO];
    }
    
    return self;
}

- (void)setBundle:(NSBundle *)bundle
{
    [_private setBundle:bundle];
}

@end

@implementation AXImgViewController_Private

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.keyboardType = UIKeyboardTypeURL;
        _textField.returnKeyType = UIReturnKeyGo;
        _textField.enablesReturnKeyAutomatically = YES;
        _textField.placeholder = @"Image URL";
        _textField.frame = CGRectMake(0, 0, 320, 28);
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.delegate = self;
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:nil];
        
        self.navigationItem.titleView = _textField;
    }
    
    return self;
}

- (void)viewDidLoad
{
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSDictionary *views = @{@"img": _imageView};
    [self.view addSubview:_imageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[img]|" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[img]|" options:kNilOptions metrics:nil views:views]];
    
    _progressView = [[UIProgressView alloc] init];
    _progressView.translatesAutoresizingMaskIntoConstraints = NO;
    _progressView.progressViewStyle = UIProgressViewStyleBar;
    
    [self.navigationController.view addSubview:_progressView];
    [self.navigationController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[prog]|" options:kNilOptions metrics:nil views:@{@"prog": _progressView}]];
    [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.navigationController.navigationBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-1]];
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:dismissGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self beginDownload];
    
    return NO;
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded)
        return;
    
    [_textField resignFirstResponder];
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle;
}

- (void)beginDownload
{
    if (_downloadTask)
        [_downloadTask cancel];
    
    _downloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:_textField.text]];
    [_downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress = ((double) totalBytesWritten / (double) totalBytesExpectedToWrite);
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSURL *finalURL = [location URLByAppendingPathExtension:@"final"];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:finalURL error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _downloadTask = nil;
        _progressView.progress = 0;
        _imageView.image = [UIImage imageWithContentsOfFile:finalURL.path];
    });
}

@end
