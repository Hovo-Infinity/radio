//
//  SCCustonActionSheet.h
//  picsart
//
//  Created by Tamara Gevorgyan on 12/10/13.
//  Copyright (c) 2013 Socialin Inc. All rights reserved.
//

#import "SCDropDownMenu.h"
#import "SCActionSheet.h"

@class SCCustomActionSheet;

@protocol SCCustomActionSheetDelegate

@optional

- (void)didSelectItem:(SCCustomActionSheet *)actionSheet atIndex:(NSInteger)idx;

@end

/// TODO: remove this class :(
@interface SCCustomActionSheet : NSObject

- (instancetype)initForView:(UIView*)view withParentViewController:(UIViewController*)parentViewController items:(NSArray*)items title:(NSString*)title tag:(int)tag delegate:(id<SCCustomActionSheetDelegate>)delegate;

- (void)close;

- (NSString *)itemTitleAtIndex:(NSInteger)idx;

@end
