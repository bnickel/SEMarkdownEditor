//
//  SEMarkdownTextChunks+Transforms.h
//  Stack Exchange
//
//  Created by Brian Nickel on 2/13/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import "SEMarkdownTextChunks.h"

@interface SEMarkdownTextChunks (Transforms)
- (void)toggleBoldface;
- (void)toggleItalics;

- (void)toggleLinkWithCreationBlock:(void(^)(SEMarkdownTextChunks *(^)(NSString *)))block;
- (void)toggleImageWithCreationBlock:(void(^)(SEMarkdownTextChunks *(^)(NSString *)))block;
- (void)toggleBlockquote;
- (void)toggleCode;

- (void)toggleOrderedList;
- (void)toggleUnorderedList;
- (void)toggleHeading;
- (void)toggleHorizontalRule;

@end
