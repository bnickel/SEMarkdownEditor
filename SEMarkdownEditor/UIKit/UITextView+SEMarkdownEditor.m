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
    [[self.undoManager prepareWithInvocationTarget:self] SE_updateWithTextChunks:[self SE_textChunksFromSelection] actionName:nil];
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
        [self scrollRectToVisible:[self firstRectForRange:self.selectedTextRange] animated:YES];
        
    }
}

@end
