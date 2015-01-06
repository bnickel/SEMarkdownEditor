//
//  UITextView+SEMarkdownEditor.h
//  SEMarkdownEditor
//
//  Created by Brian Nickel on 12/1/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>


@class SEMarkdownTextChunks;

@interface UITextView (SEMarkdownEditor)

- (SEMarkdownTextChunks *)SE_textChunksFromSelection;
- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks DEPRECATED_MSG_ATTRIBUTE("Use SE_updateWithTextChunks:actionName:");
- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks actionName:(NSString *)actionName;

@end
