//
//  UIColor+ColorWithHex.h
//  JHMail
//
//  Created by hanwei on 15/11/24.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorWithHex)

+(UIColor*)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha;
+(UIColor*)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha;

@end
