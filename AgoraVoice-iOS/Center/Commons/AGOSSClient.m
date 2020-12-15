//
//  OSSClient.m
//
//  Created by CavanSu on 2020/7/20.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AGOSSClient.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>

@implementation AGOSSObject
@end

@interface AGOSSClient ()
@property (nonatomic, strong) OSSClient *client;
@end

@implementation AGOSSClient
- (void)updateAuthServerURL:(NSString *)URL endpoint:(NSString *)endpoint {
    OSSAuthCredentialProvider *credentialProvider = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:URL];
    OSSClientConfiguration *configuration = [[OSSClientConfiguration alloc] init];
    
    self.client = [[OSSClient alloc] initWithEndpoint:endpoint
                                   credentialProvider:credentialProvider
                                  clientConfiguration:configuration];
}

- (void)uploadWithObject:(AGOSSObject *)object success:(AGOSSCompletion)succcess fail:(AGOSSErrorCompletion)fail {
    OSSPutObjectRequest *request = [OSSPutObjectRequest new];
    
    request.bucketName = object.bucket;
    request.objectKey = object.objectKey;
    request.uploadingData = object.fileData;
    request.callbackParam = object.callbackParam;
    
    OSSTask *putTask = [self.client putObject:request];
    [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {

        if (!task.error) {
            OSSPutObjectResult *uploadResult = task.result;
            
            NSData *jsonData = [uploadResult.serverReturnJsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            
            NSInteger code = [dic[@"code"] integerValue];
            NSString *message = dic[@"msg"];
            
            if (code != 0) {
                error = [NSError errorWithDomain:@"AGOSSClient"
                                            code:code
                                        userInfo:@{@"message": message}];
                
                if (fail) {
                    fail(task.error);
                }
                
                return nil;
            }
            
            NSString *logId = dic[@"data"];
            
            if (succcess) {
                succcess(logId);
            }
        } else {
            if (fail) {
                fail(task.error);
            }
        }
        return nil;
    }];
}
@end
