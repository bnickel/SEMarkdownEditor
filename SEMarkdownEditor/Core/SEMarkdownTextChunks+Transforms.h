//
//  SEMarkdownTextChunks+Transforms.h
//  Stack Exchange
//
//  Created by Brian Nickel on 2/13/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import "SEMarkdownTextChunks.h"

@interface SEMarkdownTextChunks (Transforms)

/**
 @abstract Toggles boldface text, .e.g. **strong text**.
 @discussion because bold text is an inline style any paragraph breaks in the selection will be stripped.
 */
- (void)toggleBoldface;

/**
 @abstract Toggles italicised text, e.g. *emphasized text*.
 @discussion because italicised text is an inline style any paragraph breaks in the selection will be stripped.
 */
- (void)toggleItalics;

/**
 @abstract Toggles blockquotes, inserting or removing `>` from each block in the selection.
 @warning This method is not safe for single line documents.  When applied to part of a line it will insert new lines before and after the selection.
 */
- (void)toggleBlockquote;

/**
 @abstract Toggles code formatting, applying either code block or inline code formatting.
 @discussion When applied to a whole line, empty line, or across multiple lines it will toggle block code style, inserting line breaks as necessary.  When applied to part of a line with non-whitespace characters to the right or left it will toggle inline code formatting, e.g. `inline code`.
 @warning This method may not be appropriate for single line documents.  If the markdown renderer only supports inline styling the block code format would not appear.  It may also be confusing to the user why the enter document, rather than part of the document was code formatted.
 @see toggleInlineCode
 */
- (void)toggleCode;

/**
 @abstract Toggles inline code, e.g., `inline code`.
 @discussion because inline code is an inline style any paragraph breaks in the selection will be stripped.
 @warning This method is not safe for multiline documents.  When applied to multiple lines it will strip document breaks rather than indenting code.
 @see toggleCode
 */
- (void)toggleInlineCode;


/**
 @abstract Toggles an ordered list, e.g. 1. List item
 @discussion When applied to a non-list string it converts the selection to a list item.  If an adjacent block is a list it will join that list, possibly converting it from an ordered list to an unordered list.  When applied to an item in an ordered list it will convert the whole list to an unordered list.  When applied to an item in an unordered list it will break the item out of the list as its own block level element.
 @see toggleUnorderedList
 @warning This method is not safe for single line documents.  When applied to part of a line it will insert new lines before and after the selection.
 */
- (void)toggleOrderedList;

/**
 @abstract Toggles an unordered list, e.g. - List item
 @discussion When applied to a non-list string it converts the selection to a list item.  If an adjacent block is a list it will join that list, possibly converting it from an unordered list to an ordered list.  When applied to an item in an unordered list it will convert the whole list to an ordered list.  When applied to an item in an ordered list it will break the item out of the list as its own block level element.
 @see toggleUnorderedList
 @warning This method is not safe for single line documents.  When applied to part of a line it will insert new lines before and after the selection.
 */
- (void)toggleUnorderedList;

/**
 @abstract Toggles between heading formats.
 @discussion When applied to an empty selection it will insert a hash based level 2 header, i.e. ## Heading ##.  When applied to a hash based level 2 or greater header it will convert it to a level 2 underlined header.  When applied to a level 2 underlined header or a hash based level 1 header it will convert it to a level 1 underlined header.  When applied to a level 1 underlined header it will remove the header formatting.
 @warning This method is not safe for single line documents.  In most cases it will insert or remove lines in the document.
 */
- (void)toggleHeading;


/** Replaces the selection with a horizontal rule.
 @warning This method is not safe for single line documents.  It will insert new lines.
 */
- (void)insertHorizontalRule;
- (void)toggleHorizontalRule DEPRECATED_MSG_ATTRIBUTE("Use insertHorizontalRule");

/**
 @abstract Attempts to remove a link or image.
 @discussion This method is broken in two parts as compared to the toggle methods because it depends on user interaction when adding content.  If you are attempting to toggle a link you should first call this method and if it returns @c NO then prompt the user for a new value, calling @c addLink:, @c addInlineLink: or @c addImage: as appropriate.
 @return @c YES if a link was removed, otherwise @c NO.
 */
- (BOOL)removeLinkOrImage;

/**
 @abstract Adds a reference-style link to the document.
 @see removeLinkOrImage
 @see addInlineLink:
 @warning This method is not safe for single line documents.  It will insert a reference block at the end of the document.
 */
- (void)addLink:(nonnull NSString *)linkURLAndOptionalTitle;

/**
 @abstract Adds a reference-style image to the document.
 @see removeLinkOrImage
 @warning This method is not safe for single line documents.  It will insert a reference block at the end of the document.
 */
- (void)addImage:(nonnull NSString *)imageURLAndOptionalTitle wrapInLink:(BOOL)wrapInLink;

- (void)addImage:(nonnull NSString *)imageURLAndOptionalTitle DEPRECATED_MSG_ATTRIBUTE("Use addImage:wrapInLink:");

/**
 @abstract Adds an inline link to the document, e.g. [link](http://example.com/).
 @see removeLinkOrImage
 @warning This method may not be appropriate for multiline documents.  Multiline document editors generally favor reference-style links.
 **/
- (void)addInlineLink:(nonnull NSString *)linkURLAndOptionalTitle;

@end
