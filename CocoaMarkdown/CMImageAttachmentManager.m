//
//  CMTextAttachmentManager.m
//  CocoaMarkdown
//
//  Created by Krzysztof Rodak on 06/01/16.
//  Copyright © 2016 Indragie Karunaratne. All rights reserved.
//

#import "CMImageAttachmentManager.h"
#import "AFNetworking.h"

@interface CMMarkdownImageWrapper()

@property (nonatomic, strong, nonnull) NSURL *url;
@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong, nullable) NSTextAttachment *attachment;

@end

@implementation CMMarkdownImageWrapper

+ (instancetype)imageWrapperWithURL:(nonnull NSURL*)url title:(nullable NSString*)title range:(NSRange)range {
    CMMarkdownImageWrapper *wrapper = [CMMarkdownImageWrapper new];
    wrapper.url = url;
    wrapper.title = title;
    wrapper.range = range;
    return wrapper;
}

@end

@interface CMImageAttachmentManager()

@property (nonatomic, strong, nonnull) NSMutableArray<CMMarkdownImageWrapper*> *attachments;
@property (nonatomic, strong) NSCache *cache;

@end

@implementation CMImageAttachmentManager

- (id)init {
    if (self = [super init]) {
        _attachments = [NSMutableArray new];
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)addMarkdownImageToDownload:(CMMarkdownImageWrapper*)imageWrapper
                   completionBlock:(void(^)(CMMarkdownImageWrapper* updateImage, BOOL cachedImage))completionBlock {
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:imageWrapper.url];
    [urlRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
    NSData *cachedImage = [self.cache objectForKey:urlRequest.URL.absoluteString];
    if (cachedImage) {
        
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image = [UIImage imageWithData:cachedImage];
        imageWrapper.attachment = attachment;
        imageWrapper.attachmentSize = attachment.image.size;
        completionBlock(imageWrapper, YES);

        return;
    }
    
    AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self.cache setObject:responseObject forKey:urlRequest.URL.absoluteString];
        
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image = [UIImage imageWithData:responseObject];
        imageWrapper.attachment = attachment;
        imageWrapper.attachmentSize = attachment.image.size;
        completionBlock(imageWrapper, NO);
    } failure:nil];
    
    [self.attachments addObject:imageWrapper];
    [requestOp start];
}

@end
