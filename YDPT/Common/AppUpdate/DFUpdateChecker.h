//
//  DFUpdateChecker.h
//  HWPlatform
//
//  Created by hanwei on 15/5/16.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DFUpdateCheckerDelegate <NSObject>

-(void)checkFinishedWithNewVersion:(NSString*)theNewVersion newThing:(NSString*)theNewThing;

@end

@interface DFUpdateChecker : NSObject<NSURLConnectionDelegate>{
    NSMutableData  *receivedData;
    NSURLConnection *theConncetion;
    
    id<DFUpdateCheckerDelegate> delegate;
    NSString *newVersion;
    NSString *newThings;
    
}
@property(weak,nonatomic)id<DFUpdateCheckerDelegate> delegate;
//-(void)cancelDownload;
//-(void)startCheckWithURLString:(NSString*)theURL;
-(void)checkNew:(NSString*)theURL;
-(id)init;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end