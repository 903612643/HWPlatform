//
//  MessageDataTransformer.m
//  ThatInbox
//
//  Created by hanwei on 15/10/23.
//  Copyright © 2015年 com.inkmobility. All rights reserved.
//

#import "MessageDataTransformer.h"

@implementation MessageDataTransformer

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
    MCOMessageParser *MessageData = (MCOMessageParser *)value;
    
    NSData *dataFromMessageALL = [[NSData alloc] initWithBytes:(__bridge const void * _Nullable)(MessageData) length:sizeof(MessageData)];
    
    return dataFromMessageALL;
}

/**     重新生成原对象    */
- (id)reverseTransformedValue:(id)value
{
    if (value == nil) return nil;
    
    NSData *data = (NSData *)value;
    
    MCOMessageParser *MessageData = [[MCOMessageParser alloc]init];
    
    [data getBytes:(__bridge void * _Nonnull)(MessageData) length:sizeof(MessageData)];
    
    
    return MessageData;
}


@end
