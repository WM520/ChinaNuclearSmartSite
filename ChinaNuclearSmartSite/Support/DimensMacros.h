//
//  DimensMacros.h
//  SquirrelsStore
//
//  Created by miao on 2019/9/2.
//  Copyright © 2019 三只松鼠. All rights reserved.
//

#ifndef DimensMacros_h
#define DimensMacros_h

/**
 尺寸定义的宏
 */
#define DAY_CollectionViewCellHight 44
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SizeScale (SCREEN_WIDTH == 414 ? 1.2 : (SCREEN_WIDTH == 320 ? 0.8 : 1))
#define kHeight(value) value * SizeScale
#define KRATE SCREEN_WIDTH/375.0
//kStatusBarHeight
//#define kStatusBarHeight (SCREEN_HEIGHT == 812.0 ? 44 : 20)
#define kStatusBarHeight ((is_iPhone_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 44.0 : 20.0)
#define kNavBarHeight    44
//#define kSafeAreaTopHeight (SCREEN_HEIGHT == 812.0 ? 88 : 64)
#define kSafeAreaTopHeight ((is_iPhone_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 88.0 : 64.0)
#define kSafeAreaBottomHeight ((is_iPhone_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 34 : 0)
#define kSafeAreaTabBarHeight ((is_iPhone_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 49.0 + 34.0 : 49.0)

#define kSafeAreaHeightWithNav SCREEN_HEIGHT - kSafeAreaTopHeight - kSafeAreaBottomHeight
#define kTabBarHeight        49
#define kPartitionsHeight  0.5
#define kSize(a)        ceil((a)*([UIScreen mainScreen].bounds.size.width/375.0))
/**
 判断是否是iPhone_X
 */
#define is_iPhone_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
/**
 判断是否是IS_IPhonePlus
 */
#define IS_IPhonePlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO)
/**
 判断是否是is_iPhone_SE
 */
#define is_iPhone_SE ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
/**
 判断是否是ipad
 */
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

/**
 判断iPHoneXr
 */
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
/**
 判断iPhoneXs
 */
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
/**
 判断iPhoneXs Max
 */
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)


#endif /* DimensMacros_h */
