//
//  UITextView+SEMarkdownEditor.m
//  SEMarkdownEditor
//
//  Created by Brian Nickel on 12/1/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "UITextView+SEMarkdownEditor.h"
#import "../Core/SEMarkdownTextChunks.h"


#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.2
#endif

#define SEMarkdownEditorRequiresTextViewWorkarounds() (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)

@implementation UITextView (SEMarkdownEditor)

- (SEMarkdownTextChunks *)SE_textChunksFromSelection
{
    return [[SEMarkdownTextChunks alloc] initWithText:self.text selection:self.selectedRange];
}

- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks
{
    [self SE_updateWithTextChunks:chunks actionName:nil];
}

- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks actionName:(NSString *)actionName
{
    [self SE_updateWithTextChunks:chunks actionName:actionName animated:YES];
}

- (void)SE_updateWithTextChunks:(SEMarkdownTextChunks *)chunks actionName:(NSString *)actionName animated:(BOOL)animated
{
    [[self.undoManager prepareWithInvocationTarget:self] SE_updateWithTextChunks:[self SE_textChunksFromSelection] actionName:actionName animated:animated];
    if (actionName) {
        [self.undoManager setActionName:actionName];
    }
    
    [self becomeFirstResponder];
    
    CGPoint originalOffset = self.contentOffset;
    
    NSRange range;
    self.text = [chunks textWithSelection:&range];
    self.selectedRange = range;
    
    if SEMarkdownEditorRequiresTextViewWorkarounds() {
        
        // 1. Prevent the text view content size from radically changing on update.
        UIGraphicsBeginImageContext(self.bounds.size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIGraphicsEndImageContext();
        
        // 2. Move the scroll view back to the original location.
        self.contentOffset = originalOffset;
        
        // 3. Scroll to the new content.
        [self layoutSubviews]; // Required for iOS7.
        [self SE_scrollRectToVisibleConsideringInsets:[self caretRectForPosition:self.selectedTextRange.end] animated:animated];
    }
}

// Copied from https://github.com/steipete/PSPDFTextView/blob/f53c03a5024cdeb6761598314abc8e5e2900bb02/PSPDFTextView/PSPDFTextView.m#L88 under MIT license.

- (void)SE_scrollRectToVisibleConsideringInsets:(CGRect)rect animated:(BOOL)animated
{
    if SEMarkdownEditorRequiresTextViewWorkarounds() {
        
        // Don't scroll if rect is currently visible.
        UIEdgeInsets insets = UIEdgeInsetsMake(self.contentInset.top + self.textContainerInset.top,
                                               self.contentInset.left + self.textContainerInset.left,
                                               self.contentInset.bottom + self.textContainerInset.bottom,
                                               self.contentInset.right + self.textContainerInset.right);
        CGRect visibleRect = UIEdgeInsetsInsetRect(self.bounds, insets);
        
        if (!CGRectContainsRect(visibleRect, rect)) {
            
            // Calculate new content offset.
            CGPoint contentOffset = self.contentOffset;
            
            if (CGRectGetMinY(rect) < CGRectGetMinY(visibleRect)) { // scroll up
                contentOffset.y = CGRectGetMinY(rect) - insets.top;
            } else { // scroll down
                contentOffset.y = CGRectGetMaxY(rect) + insets.bottom - CGRectGetHeight(self.bounds);
            }
            
            [self setContentOffset:contentOffset animated:animated];
        }
        
    } else {
        [self scrollRectToVisible:rect animated:animated];
    }
}

@end
