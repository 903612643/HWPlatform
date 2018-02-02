//
//  JSInterfaceTest.h
//  HWPlatform
//
//  Created by hanwei on 15/8/10.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyJSDataFunction.h"

@interface JSInterfaceTest : NSObject

- (void) test;
- (void) testWithParam: (NSString*) param;
- (void) testWithTwoParam: (NSString*) param AndParam2: (NSString*) param2;
- (void) openapplication: (NSString*) param AndParam2: (NSString*) param2;

- (void) testWithFuncParam: (EasyJSDataFunction*) param;
- (void) testWithFuncParam2: (EasyJSDataFunction*) param;

- (NSString*) testWithRet;

@end
