//
//  HeaderDataTransformer.m
//  ThatInbox
//
//  Created by hanwei on 15/10/20.
//  Copyright © 2015年 com.inkmobility. All rights reserved.
//

#import "HeaderDataTransformer.h"

@implementation HeaderDataTransformer

/**     允许转换    */
+ (BOOL)allowsReverseTransformation
{
    return YES;
}

/**     转换成什么类    */
+ (Class)transformedValueClass
{
    return [NSData class];
}

/**     返回转换后的对象    */
- (id)transformedValue:(id)value
{
    if (value == nil) return nil;
    
    // 将MCOMessageHeader转成NSData
    MCOMessageHeader *HeaderData = (MCOMessageHeader *)value;
    
    NSData *dataFromMessage = [[NSData alloc] initWithBytes:(__bridge const void * _Nullable)(HeaderData) length:sizeof(HeaderData)];
    
    return dataFromMessage;
}

/**     重新生成原对象    */
- (id)reverseTransformedValue:(id)value
{
    if (value == nil) return nil;
    
    NSData *data = (NSData *)value;
    
    MCOMessageHeader *HeaderData = [[MCOMessageHeader alloc] init];
    
    [data getBytes:(__bridge void * _Nonnull)(HeaderData) length:sizeof(HeaderData)];
    
    
    return HeaderData;
}

@end
