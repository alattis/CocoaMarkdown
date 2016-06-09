//
//  CMAttributedStringRenderer.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMDocument;
@class CMTextAttributes;
@class UITextView;
@class CMImageAttachmentManager;

@protocol CMHTMLElementTransformer;

@protocol CMAttributedStringRendererDelegate <NSObject>

- (void) rendererDidUpdateAttributedString;

@end

/**
 *  Renders an attributed string from a Markdown document
 */
@interface CMAttributedStringRenderer : NSObject

@property (nonatomic, weak) id <CMAttributedStringRendererDelegate> delegate;
@property (nonatomic, readonly) CMImageAttachmentManager *attachmentsManager;

/**
 *  Designated initializer.
 *
 *  @param document   A Markdown document.
 *  @param attributes Attributes used to style the string.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes;

/**
 *  Registers a handler to transform HTML elements.
 *
 *  Only a single transformer can be registered for an element. If a transformer
 *  is already registered for an element, it will be replaced.
 *
 *  @param transformer The transformer to register.
 */
- (void)registerHTMLElementTransformer:(id<CMHTMLElementTransformer>)transformer;

/**
 *  Renders an attributed string from the Markdown document.
 *
 *  @return An attributed string containing the contents of the Markdown document,
 *  styled using the attributes set on the receiver.
 */
- (NSAttributedString *)render;


/**
 * Renders an attributed string from initialized Markdown document and keeps it with sync in the @c UITextView.
 *
 * This method aims to support asynchronous data loading which may be included in Markdown document, i.e. images linked by URL.
 */
- (void)renderAndSyncWithTextView:(UITextView*)textView;


@end
