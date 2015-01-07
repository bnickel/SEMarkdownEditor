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

/**
 @abstract Convenience methods for performing markdown transforms on a @c UITextView.
 @discussion The standard mechanism for applying a transform is to call @c SE_textChinksFromSelection, call the appropriate method to transform the text, e.g. @c toggleCode, and then update the text view with @c SE_updateWithTextChunks:actionName:.
 */
@interface UITextView (SEMarkdownEditor)

/**
 @abstract Extracts a @c SEMarkdownTextChunks version of the current text and selection.
 @return A new instance of @c SEMarkdownTextChunks representing the contents of the text view.
 @see SEMarkdownTextChunks
 */
- (SEMarkdownTextChunks *)SE_textChunksFromSelection;

/**
 @abstract Updates the text view's text and selection with the values from the text chunk.
 @discussion This method includes bug fixes for iOS7+ to ensure a smooth animation to the new selection.  It has been tested with @c UITextView and @c PSPDFTextView in iOS 7.1 and iOS 8.1.
 @param chunks An instance of @c SEMarkdownTextChunks containing the transformed text and selection.
 @param actionName The action name to use when registering the selection with the @c NSUndoManager.  If @ nil no name is set.
 @see SE_updateWithTextChunks:actionName:animated:
 */
- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks actionName:(NSString *)actionName;
- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks DEPRECATED_MSG_ATTRIBUTE("Use SE_updateWithTextChunks:actionName:");

/**
 @abstract Updates the text view's text and selection with the values from the text chunk.
 @discussion This method includes bug fixes for iOS7+ to ensure a smooth animation to the new selection.  It has been tested with @c UITextView and @c PSPDFTextView in iOS 7.1 and iOS 8.1.
 @param chunks An instance of @c SEMarkdownTextChunks containing the transformed text and selection.
 @param actionName The action name to use when registering the selection with the @c NSUndoManager.  If @ nil no name is set.
 @param animated Whether or not to animate scrolling ot the new selection.
 */
- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks actionName:(NSString *)actionName animated:(BOOL)animated;

@end
