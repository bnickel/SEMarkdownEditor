//
//  UITextView+SEMarkdownEditor.h
//  SEMarkdownEditor
//
//  Created by Brian Nickel on 12/1/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SEMarkdownTextChunks;

@interface UITextView (SEMarkdownEditor)

- (SEMarkdownTextChunks *)SE_textChunksFromSelection;
- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks;

@end
