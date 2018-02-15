//
//  SCCustomAlertView.m
//  picsart
//
//  Created by Tamara Gevorgyan on 10/3/13.
//  Copyright (c) 2013 Socialin Inc. All rights reserved.
//

#import "SCCustomAlertView.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+Socialin.h"

const static CGFloat kCustomAlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomAlertViewDefaultButtonSpacerHeight = 1;
const static CGFloat kCustomAlertViewCornerRadius              = 7;
const static CGFloat kCustomMotionEffectExtent                 = 10.0;

@interface SCCustomAlertView ()

@end

@implementation SCCustomAlertView {
    CAGradientLayer* gradientBGLayer;
    BOOL isClosedByUser;
    UIColor* buttonDefColor;
    
    NSMutableArray *buttonsAndDividers;
    
    CGFloat buttonHeight;
    CGFloat buttonSpacerHeight;
}

+ (NSArray *)createOkCancelButtonProps {
    NSString* title = SCLocalizedString(@"gen_cancel", nil);
    UIFont* font = [UIFont systemFontOfSize:16];
    NSDictionary* cancelDict = @{SCAlertButtonTitle: title, SCAlertButtonTitleFont: font};
    
    title = SCLocalizedString(@"gen_ok", nil);

    font = [UIFont boldSystemFontOfSize:16];
    NSDictionary* okDict = @{SCAlertButtonTitle: title, SCAlertButtonTitleFont: font};
    
    return @[cancelDict, okDict];
}


+ (NSArray *)createDoneCancelButtonPropsWithEnableDone:(BOOL)enable {
    NSString* title = SCLocalizedString(@"gen_cancel", nil);
    UIFont* font = [UIFont systemFontOfSize:16];
    NSDictionary* cancelDict = @{SCAlertButtonTitle: title, SCAlertButtonTitleFont: font};
    
    title = SCLocalizedString(@"gen_done", nil);
    
    font = [UIFont boldSystemFontOfSize:16];
    NSDictionary* okDict = @{SCAlertButtonTitle: title, SCAlertButtonTitleFont: font, SCAlertButtonEnabled : @(enable), SCAlertButtonDisableColor : [UIColor colorFromHex:0xCCCCCC]};
    
    return @[cancelDict, okDict];
}


static UIImage *highlitedImage;

- (instancetype)initWithNibName:(NSString *)nibName {
    return [self initWithParentView:nil nibName:nibName];
}

- (instancetype)initWithParentView:(UIView *)parentView
                          nibName:(NSString *)nibName {
    self = [super initWithFrame:_parentView.bounds];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight;
        self.parentView = parentView;
        self.delegate = self;
        self.buttonProps = @[SCLocalizedString(@"gen_close",nil)];
        buttonDefColor = [UIColor colorWithRed:71.0f / 255.f green:119.f / 255.f blue:255.f / 255.f alpha:1.0f];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appOpenedFromAnotherApp:)
                                                     name:kSCApplicationWillOpenFromAnotherApplication
                                                   object:nil];
        if (nibName) {
            NSArray* subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
            UIView* contentView = [subViews objectAtIndex:0];
            contentView.clipsToBounds = YES;
            self.containerView = contentView;
        }
        if (highlitedImage == nil) {
            highlitedImage = [UIImage imageWithColor:[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0f] size:CGSizeMake(1, 1)];
        }
        self.dialogView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setParentView:(UIView *)parentView {
    _parentView = parentView;
    self.frame = _parentView.bounds;
    [self correctLayout];
}

- (void)setButtonProps:(NSArray *)buttonProps {
    _buttonProps = buttonProps;
    [self addButtonsToView:self.containerView.superview];
}

- (void)updateButtonProps:(NSArray *)buttonProps {
    self.buttonProps = buttonProps;
    NSLog(@"*********************************** setButtonProps called");
    [self.dialogView removeFromSuperview];
    self.dialogView = [self createContainerView];
    [self addSubview:self.dialogView];
}

- (instancetype)initWithParentView:(UIView *)parentView {
    return [self initWithParentView:parentView nibName:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self correctLayout];
}

- (void)correctLayout {
    gradientBGLayer.frame = self.dialogView.bounds;
    self.dialogView.center = CGPointMake(self.superview.bounds.size.width / 2,
                                    self.superview.bounds.size.height / 2);
}

// Create the dialog view, and animate opening the dialog
- (void)show {
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.dialogView = [self createContainerView];
    
    _dialogView.autoresizingMask = UIViewAutoresizingNone;
    
    if(self.useMotionEffects)
        [self applyMotionEffects];
    
    _dialogView.layer.opacity = 0.0f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    [self addSubview:_dialogView];
    [self.parentView addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];
}

// Button has touched
- (IBAction)customdialogButtonTouchUpInside:(id)sender {
    if ([self.delegate respondsToSelector:@selector(customdialogButtonTouchUpInside:clickedButtonAtIndex:)]) {
        [self.delegate customdialogButtonTouchUpInside:self clickedButtonAtIndex:(int)[sender tag]];
    }
}

- (IBAction)cancel:(UIButton *)sender {
    [self customdialogButtonTouchUpInside:sender];
}
// Default button behaviour
- (void)customdialogButtonTouchUpInside:(SCCustomAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex {
    [self close];
}

- (void)close:(BOOL)animated {
    if (animated) {
//        dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
//        dialogView.layer.opacity = 1.0f;
        
        
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                             _dialogView.layer.transform = CATransform3DMakeScale(0.6f, 0.6f, 1.0);
                             _dialogView.layer.opacity = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             if ([self.delegate respondsToSelector:@selector(modalView:isClosedByUser:)]) {
                                 [self.delegate modalView:self isClosedByUser:isClosedByUser];
                             }
                             isClosedByUser = NO;
                             [self removeFromSuperview];
                         }
         ];
    } else {
        if ([self.delegate respondsToSelector:@selector(modalView:isClosedByUser:)]) {
            [self.delegate modalView:self isClosedByUser:isClosedByUser];
        }
        isClosedByUser = NO;
        [self removeFromSuperview];
    }
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close {
    isClosedByUser = YES;
    [self close:YES];
}

- (void)setSubView: (UIView *)subView {
    self.containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView {
    [_dialogView removeFromSuperview];
    if (self.buttonProps.count > 0) {
        buttonHeight       = kCustomAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }
    
    if (_containerView == NULL) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
    
    CGFloat dialogWidth = _containerView.frame.size.width;
    CGFloat dialogHeight = _containerView.frame.size.height + buttonHeight + buttonSpacerHeight;
    
    CGFloat screenWidth = _parentView.bounds.size.width;
    CGFloat screenHeight = _parentView.bounds.size.height;
    
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - dialogWidth) / 2, (screenHeight - dialogHeight) / 2, dialogWidth, dialogHeight)];
    
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    gradientBGLayer = [CAGradientLayer layer];
    gradientBGLayer.frame = dialogContainer.bounds;
    gradientBGLayer.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];
    
    CGFloat cornerRadius = kCustomAlertViewCornerRadius;
    gradientBGLayer.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradientBGLayer atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.clipsToBounds = YES;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    
    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    lineView.backgroundColor = [UIColor lightGrayColor];//TODO!!!
    [dialogContainer addSubview:lineView];
    // ^^^
    
    // Add the custom container if there is any
    [dialogContainer addSubview:_containerView];
    
    // Add the buttons too
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

- (void)addButtonsToView:(UIView *)container {
    for (UIView *cur in buttonsAndDividers) {
        [cur removeFromSuperview];
    }
    buttonsAndDividers = [NSMutableArray arrayWithCapacity:self.buttonProps.count];
    
    
    CGFloat buttonWidth = container.bounds.size.width / self.buttonProps.count;
    
    for (int i = 0 ; i < self.buttonProps.count; i++) {
        id curProp = self.buttonProps[i];
        UIColor* titleColor = buttonDefColor;
        UIColor *disableColor = [UIColor grayColor];
        UIColor* titleHighlitedColor = buttonDefColor;
        UIFont* font = [UIFont boldSystemFontOfSize:14.0f];
        BOOL enable = YES;
        NSString* title = @"";
        if ([curProp isKindOfClass:[NSString class]]) {
            title = curProp;
        } else {
            NSDictionary* propsDict = curProp;
            if(propsDict[SCAlertButtonTitle] != nil) title = propsDict[SCAlertButtonTitle];
            if(propsDict[SCAlertButtonTitleColor] != nil) titleColor = propsDict[SCAlertButtonTitleColor];
            if(propsDict[SCAlertButtonTitleHighlitedColor] != nil)
                titleHighlitedColor = propsDict[SCAlertButtonTitleHighlitedColor];
            if(propsDict[SCAlertButtonTitleFont] != nil) font = propsDict[SCAlertButtonTitleFont];
            if(propsDict[SCAlertButtonEnabled] != nil) enable = [propsDict[SCAlertButtonEnabled] boolValue];
            if(propsDict[SCAlertButtonDisableColor] != nil) disableColor = propsDict[SCAlertButtonDisableColor];
        }
        UIButton *curButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [curButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)];
        
        [curButton addTarget:self action:@selector(customdialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [curButton setTag:i];
        curButton.enabled = enable;
        [curButton setTitle:title forState:UIControlStateNormal];
        [curButton setTitleColor:titleColor forState:UIControlStateNormal];
        [curButton setTitleColor:disableColor forState:UIControlStateDisabled];
        [curButton setTitleColor:titleHighlitedColor forState:UIControlStateHighlighted];
        
        [curButton setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        [curButton.titleLabel setFont:font];
        curButton.clipsToBounds = YES;
        [container addSubview:curButton];
        [buttonsAndDividers addObject:curButton];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, 1, buttonHeight)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        if (i != 0) {
            [container addSubview:lineView];
            [buttonsAndDividers addObject:lineView];
        }
    }
}

// Add motion effects
- (void)applyMotionEffects {
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomMotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomMotionEffectExtent);
    
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomMotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomMotionEffectExtent);
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
    
    [self.dialogView addMotionEffect:motionEffectGroup];
}

- (void)appOpenedFromAnotherApp:(NSNotification*)notification {
    [self close];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (touch.view == self) {
        [self close];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
