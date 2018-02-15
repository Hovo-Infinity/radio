//
//  SCCustomAlertView.h
//  picsart
//
//  Created by Tamara Gevorgyan on 10/3/13.
//  Copyright (c) 2013 Socialin Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCAlertButtonTitle  @"button_title"
#define SCAlertButtonTitleColor  @"button_title_color"
#define SCAlertButtonDisableColor @"button_disable_title_color"
#define SCAlertButtonTitleHighlitedColor  @"button_title_highlited_color"
#define SCAlertButtonTitleFont  @"button_title_font"
#define SCAlertButtonBackgroundColor @"button_background_color"
#define SCAlertButtonEnabled @"button_enabled"

@class SCCustomAlertView;
@protocol SCCustomAlertViewDelegate <NSObject>

@optional
- (void)modalView:(SCCustomAlertView *)modalView isClosedByUser:(BOOL)byUser;
- (void)customdialogButtonTouchUpInside:(id)sender clickedButtonAtIndex:(int)idx;

@end

@interface SCCustomAlertView : UIView<SCCustomAlertViewDelegate>

+ (NSArray *)createOkCancelButtonProps;
+ (NSArray *)createDoneCancelButtonPropsWithEnableDone:(BOOL)enable;

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, weak) id<SCCustomAlertViewDelegate> delegate;

//props can be array of button titles as NSString or array of dictionary
@property(nonatomic) NSArray *buttonProps;

- (id)initWithParentView: (UIView *)_parentView;
- (instancetype)initWithNibName:(NSString *)nibName;
- (instancetype)initWithParentView:(UIView *)_parentView
                          nibName:(NSString *)nibName;

- (void)show;
- (void)close:(BOOL)animated;
- (void)correctLayout;

//- (void)modalView:(SCCustomAlertView *)modalView isClosedByUser:(BOOL)byUser;
- (IBAction)customdialogButtonTouchUpInside:(id)sender;
- (IBAction)cancel:(UIButton *)sender;
- (void)updateButtonProps:(NSArray *)buttonProps;

@property(nonatomic) BOOL useMotionEffects;

@end
