//
//  TPDCard.h
//
//  Copyright © 2017年 Cherri Tech, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPDStatus;

@interface TPDForm : UIView

#pragma mark - Initialize

/**
 This Method Will Set Up TPDForm And Return TPDForm Instance
 
 
 @param view (UIView *)view  ,Use Your Customized View To Display TPDForm.
 @return TPDForm Instance
 */
+ (instancetype)setupWithContainer:(UIView *)view;


#pragma mark - Function

/**
 Updated Current TPDStatus 

 @param callback (TPDStatus *_Nonnull status)
 @return TPDForm Instance
 */
-(instancetype _Nonnull)onFormUpdated:(void(^_Nonnull)(TPDStatus *_Nonnull status))callback;

/**
 Set Error Status TextField TextColor

 @param color
 */
- (void)setErrorColor:(UIColor * _Nonnull)color;

/**
 Set OK Status TextField TextColor

 @param color
 */
- (void)setOkColor:(UIColor * _Nonnull)color;

/**
 Set Normal Status TextField TextColor

 @param color
 */
- (void)setNormalColor:(UIColor * _Nonnull)color;


/**
 
 @return NSString, CardNumber
 */

- (NSString *)getCardNumber;

/**
 
 @return NSString, Due Month
 */
- (NSString *)getDueMonth;

/**

 @return NSString, Due Year
 */
- (NSString *)getDueYear;

/**
 
 @return NSString, CCV.
 */
- (NSString *)getCCV;


/**
 Show Off Keyboard
 */
- (void)showOffKeyboard;

@end
