//
//  SCCustonActionSheet.m
//  picsart
//
//  Created by Tamara Gevorgyan on 12/10/13.
//  Copyright (c) 2013 Socialin Inc. All rights reserved.
//

#import "SCCustomActionSheet.h"

@interface SCCustomActionSheet () <SCActionSheetDelegate, SCDropDownMenuDelegate>

@property (nonatomic) id sheet;
@property (nonatomic, weak) id<SCCustomActionSheetDelegate> delegate;

@end

@implementation SCCustomActionSheet

- (instancetype)initForView:(UIView*)view withParentViewController:(UIViewController*)parentViewController items:(NSArray*)items title:(NSString *)title tag:(int)tag delegate:(id<SCCustomActionSheetDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        if (SCIsiPad) {
            SCDropDownMenu* dropDownMenu = [SCDropDownMenu dropDownMenuForView:view withParentView:parentViewController.view style:SCDropDownMenuAppearenceStyleWhite items:items];
            self.sheet = dropDownMenu;
            dropDownMenu.delegate = self;
            dropDownMenu.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            dropDownMenu.tag = tag;
            [dropDownMenu openWithAnimationStyle:SCDropDownMenuAnimationStyleAlpha];
        } else {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SCActionSheet *actionSheet = [[SCActionSheet alloc] initWithTitle:nil
                                                                cancelButtonTitle:SCLocalizedString(@"gen_cancel", nil)
                                                           destructiveButtonTitle:nil
                                                                            items:items
                                                                         delegate:self];
                self.sheet = actionSheet;
                actionSheet.tag = tag;
                [parentViewController presentViewController:actionSheet animated:YES completion:0];
            });
        }
    }
    return self;
}

- (void)close {
    if ([self.sheet isKindOfClass:[SCDropDownMenu class]]) {
        [(SCDropDownMenu *)self.sheet closeWithAnimationStyle:SCDropDownMenuAnimationStyleAlpha];
    }
}

- (NSString *)itemTitleAtIndex:(NSInteger)idx {
    if ([self.sheet isKindOfClass:[SCDropDownMenu class]]) {
        SCDropDownMenuItemData *data = [(SCDropDownMenu *)self.sheet itemDataAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        return data.title;
    } else {
        return [self.sheet buttonTitleAtIndex:idx];
    }
}

#pragma mark - SCActionSheetDelegate

- (void)actionSheet:(SCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.delegate didSelectItem:self atIndex:buttonIndex];
}

#pragma mark - SCDropDownMenuDelegate

-(void)dropDownMenu:(SCDropDownMenu*)menu didSelectedItemAtIndex:(int)index {
    [self.delegate didSelectItem:self atIndex:index];
}

-(void)dropDownMenu:(SCDropDownMenu*)menu didSelectedItemAtIndex:(int)index inSection:(int)section {
    [self.delegate didSelectItem:self atIndex:index];
}


@end
