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
    [self.undoManager registerUndoWithTarget:self selector:@selector(SE_updateWithTextChunks:) object:[self SE_textChunksFromSelection]];
    
    [self becomeFirstResponder];
    
    NSRange range;
    self.text = [chunks textWithSelection:&range];
    self.selectedRange = range;
    
    
    if SEMarkdownEditorRequiresTextViewWorkarounds() {
        
        // Prevents the text view content size from radically changing on update.
        UIGraphicsBeginImageContext(self.bounds.size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIGraphicsEndImageContext();
        
        // Triggers scrolling to the selection.
        [self setNeedsLayout];
    }
    
}

@end
