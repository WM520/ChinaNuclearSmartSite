//
//  ZFScanViewController.h
//  ZFScan
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFConst.h"

@interface ZFScanViewController : UIViewController

/** 扫描结果 */
@property (nonatomic, copy) void (^returnScanBarCodeValue)(NSString * barCodeString);
/** 报修处的扫描 */
@property (nonatomic, assign) BOOL isWarranty;
/** 扫描直接充电 */
@property (nonatomic, assign) BOOL isPower;

@end
