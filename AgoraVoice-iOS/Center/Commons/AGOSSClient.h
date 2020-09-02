//
//  OSSClient.h
//
//  Created by CavanSu on 2020/7/20.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AGOSSCompletion)(NSString *);
typedef void (^AGOSSErrorCompletion)(NSError *error);

@interface AGOSSObject : NSObject
@property (nonatomic, copy) NSDictionary *callbackParam;
@property (nonatomic, copy) NSString *objectKey;
@property (nonatomic, copy) NSString *bucket;
@property (nonatomic, strong) NSData *fileData;
@end

@interface AGOSSClient : NSObject
- (void)updateAuthServerURL:(NSString *)URL endpoint:(NSString *)endpoint;
- (void)uploadWithObject:(AGOSSObject *)object success:(AGOSSCompletion)succcess fail:(AGOSSErrorCompletion)fail;
@end

NS_ASSUME_NONNULL_END
