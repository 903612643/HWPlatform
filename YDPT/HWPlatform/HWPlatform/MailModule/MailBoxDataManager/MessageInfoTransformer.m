//
//  MessageInfoTransformer.m
//  ThatInbox
//
//  Created by hanwei on 15/10/22.
//  Copyright © 2015年 com.inkmobility. All rights reserved.
//

#import "MessageInfoTransformer.h"

@implementation MessageInfoTransformer
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
    MCOPOPMessageInfo *HeaderData = (MCOPOPMessageInfo *)value;
    
    NSData *dataFromMessage = [[NSData alloc] initWithBytes:CFBridgingRetain(HeaderData) length:sizeof(HeaderData)];
    
    return dataFromMessage;
}

/**     重新生成原对象    */
- (id)reverseTransformedValue:(id)value
{
    if (value == nil) return nil;
    
    NSData *data = (NSData *)value;
    
    MCOPOPMessageInfo *MessageInfoData = [[MCOPOPMessageInfo alloc] init];
    
    [data getBytes:(__bridge void * _Nonnull)(MessageInfoData) length:sizeof(MessageInfoData)];
    
    
    return MessageInfoData;
}

@end
