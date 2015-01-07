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

- (void)toggleBlockquote;
- (void)toggleCode;
- (void)toggleInlineCode;

- (void)toggleOrderedList;
- (void)toggleUnorderedList;
- (void)toggleHeading;
- (void)toggleHorizontalRule;

/**
 @abstract Attempts to remove a link or image.
 @discussion This method is broken in two parts as compared to the toggle methods because it depends on user interaction when adding content.  If you are attempting to toggle a link you should first call this method and if it returns @c NO then prompt the user for a new value, calling @c addLink: or @c addImage: as appropriate.
 @return @c YES if a link was removed, otherwise @c NO.
 */
- (BOOL)removeLinkOrImage;

/**
 @abstract Adds a reference-style link to the document.
 @see removeLinkOrImage
 */
- (void)addLink:(NSString *)linkURLAndOptionalTitle;

/**
 @abstract Adds a link to the document.
 @see removeLinkOrImage
 */
- (void)addImage:(NSString *)imageURLAndOptionalTitle;

/**
@abstract Adds a link to the document with an inline format
 e.g. [link](http://example.com)
 @see removeLinkOrImage
 **/
- (void)addInlineLink:(NSString *)linkURLAndOptionalTitle;

@end
