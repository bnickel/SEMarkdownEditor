//
//  SEMarkdownTextChunks.h
//  Stack Exchange
//
//  Created by Brian Nickel on 2/13/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract Represents a string of text and its selection in a way that simplifies markdown operations.
 */
@interface SEMarkdownTextChunks : NSObject<NSCopying>

/**
 @abstract Returns an initialized @c SEMarkdownTextChunks representing the string and the selection.
 @discussion Initially the text inside the selection range will be stored in the @c selection with the surrounding text stored in @c before and @c after.
 */
- (instancetype)initWithText:(NSString *)text selection:(NSRange)selection;

/**
 @abstract Returns the string and selected range represented by the current instance.
 @param selectedRange An optional range pointer to be populated with the range of the selection in the returned text.
 @return The string represented by the current instance.
 */
- (NSString *)textWithSelection:(out NSRangePointer)selectedRange;

/**
 @abstract The text before the selection and the start tag.
 */
@property (nonatomic) NSString *before;

/**
 @abstract The text immediately before selection that relates to the tag.
 @discussion This is generally populated by @c findLeft:andRightTags: but may also be used by transformation inserting text to avoid concatenating in @c before.
 @see findLeft:andRightTags:
 */
@property (nonatomic) NSString *startTag;

/**
 @abstract The text representing the selection.  Before any transforms are performed this generally represents the text selected by the user.  Afterwards it represents the text that should be selected when updating the text.
 */
@property (nonatomic) NSString *selection;

/**
 @abstract The text immediately after selection that relates to the tag.
 @discussion This is generally populated by @c findLeft:andRightTags: but may also be used by transformation inserting text to avoid concatenating in @c after.
 @see findLeft:andRightTags:
 */
@property (nonatomic) NSString *endTag;

/**
 @abstract The text after the selection and the end tag.
 */
@property (nonatomic) NSString *after;

/**
 @abstract Trims whitespace from the selection moving it to @c before and @c after or optionally discarding it.
 @param remove When @c YES the trimmed whitespace is discarded.
 */
- (void)trimWhitespaceAndRemove:(BOOL)remove;

/**
 @abstract Tries finding the matching patterns at the the edges of @c selection, @c before, and @c after, moving it to @c startTag and @c endTag.
 @discussion The expressions are anchored to the edges of the strings they test (using ^ and $).
 @param startExpr The pattern for the start tag, e.g. "\\[" for the start of an inline link.
 @param endExpr The pattern for the end tag, e.g. "\\]\\(.*?\\)" for the end of an inline link.
 */
- (void)findLeft:(NSString *)startExpr andRightTags:(NSString *)endExpr;

/**
 @abstract Adds blank lines before and after the selection or tags to ensure a minimum number of blank lines, optionally removing additional blank lines.
 @discussion This is used for ensuring new block level elements have the required spacing to render correctly.  For example, a code block requires a blank line preceeding and following the block.  To ensure extraneous new lines are not added, leading and trailing newlines are pushed from the selection to the tags and then from the tags to @c before and @c after.
 @param numberOfLinesBefore The number of lines required before the selection.
 @param numberOfLinesAfter The number of lines required after the selection.
 @param findExtraNewLines If @c YES the method will strip additional blank lines found before or after the so that the final number of blank lines matches @c numberOfLinesBefore and @c numberOfLinesAfter.
 */
- (void)skipLinesBack:(NSInteger)numberOfLinesBefore forward:(NSInteger)numberOfLinesAfter findExtraNewlines:(BOOL)findExtraNewlines;

/**
 @abstract Inserts linebreaks into the selection so that no line longer than a specified number of characters.
 @param length The maximum length for a given line.
 */
- (void)wrapWithLength:(NSInteger)length;

/**
 @abstract Removes non-printing line breaks from the selection.
 */
- (void)unwrap;

@end
