//
//  CSBundle.h
//  CSSE477HW2
//
//  Created by James Savage on 9/30/13.
//  Copyright (c) 2013 David Savrda. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CSBundlePostStatusUpdateNotification @"CSBundlePostStatusUpdateNotification"
#define CSBundlePostStatusUpdateMessageKey @"CSBundlePostStatusUpdateMessage"

@protocol CSBundle <NSObject>

- (void)setBundle:(NSBundle *)bundle;

@end
