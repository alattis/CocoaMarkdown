//
//  CMTextAttachmentManager.m
//  CocoaMarkdown
//
//  Created by Krzysztof Rodak on 06/01/16.
//  Copyright © 2016 Indragie Karunaratne. All rights reserved.
//

#import "CMImageAttachmentManager.h"
#import "AFImageDownloader.h"

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
@property (nonatomic, strong, nullable) AFHTTPSessionManager *httpManager;

@end

@implementation CMImageAttachmentManager

- (id)init {
    if (self = [super init]) {
        _attachments = [NSMutableArray new];
        _cache = [[NSCache alloc] init];
        _httpManager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)addMarkdownImageToDownload:(CMMarkdownImageWrapper*)imageWrapper
                   completionBlock:(void(^)(CMMarkdownImageWrapper* updateImage, BOOL cachedImage))completionBlock {
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:imageWrapper.url];
    [urlRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    UIImage *cachedImage = [self.cache objectForKey:imageWrapper.url.absoluteString];
    if (cachedImage && [cachedImage isKindOfClass:[UIImage class]]) {
        
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image =cachedImage;
        imageWrapper.attachment = attachment;
        imageWrapper.attachmentSize = attachment.image.size;
        completionBlock(imageWrapper, YES);

        return;
    }
    
    [[AFImageDownloader defaultInstance] downloadImageForURLRequest:urlRequest success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[UIImage class]]) {
            [self.cache setObject:responseObject forKey:imageWrapper.url.absoluteString];
            
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.image = responseObject;
            imageWrapper.attachment = attachment;
            imageWrapper.attachmentSize = attachment.image.size;
            completionBlock(imageWrapper, NO);
        }
    } failure:nil];

}

@end
