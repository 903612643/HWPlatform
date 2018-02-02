//
//  DFUpdateChecker.m
//  HWPlatform
//
//  Created by hanwei on 15/5/16.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFUpdateChecker.h"

@implementation DFUpdateChecker
@synthesize delegate;


-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [connection release];
    [receivedData release];
    NSLog(@"Error!!!!!! 检测版本失败");
    //检测版本失败伪装返回最新版本
    [self.delegate checkFinishedWithNewVersion:@"Newest" newThing:@""];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSString *result;
    
    result=[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSString *content;
    content=[result stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    [connection release];
    [receivedData release];
    
    if([content isEqualToString:@"Newest"]==YES){
        newVersion=@"Newest";
        newThings=@"";
    }else{
        newVersion=[[content componentsSeparatedByString:@"[New]"] objectAtIndex:0];
        newThings=[[content componentsSeparatedByString:@"[New]"] objectAtIndex:1];
        newThings=[content stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    }

    [self.delegate checkFinishedWithNewVersion:newVersion newThing:newThings];
}

-(void)dealloc{
    [super dealloc];
}

-(void)cancelDownload
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [theConncetion cancel];
    theConncetion = nil;
    receivedData = nil;
}

-(NSString*)getNowVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *result_=[infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return result_;
}

-(void)checkNew:(NSString*)theURL{
    [self startCheckWithURLString:[NSString stringWithFormat:theURL,[self getNowVersion]]];
//    [self startCheckWithURLString:[NSString stringWithFormat:@"https://www.hanweikeji.com/app/CheckUpdate.asp?type=%@",[self getNowVersion]]];
}

-(id) init{
    self = [super init];
    if (self != nil){
        self.delegate= nil;
    }
    return self;
}

//-(id) initWithDelegate:(id<DFUpdateCheckerDelegate>) delegate{
//    self = [super init];
//    if (self != nil){
//        self.delegate = delegate;
//    }
//    return self;
//}

-(void)startCheckWithURLString:(NSString*)theURL{
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:theURL] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:2.0];
    theConncetion=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(theConncetion){
        receivedData=[[NSMutableData data] retain];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    }else{
        NSLog(@"Can't start the connection!");
    }
}

@end

