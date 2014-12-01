//
//  UITextView+SEMarkdownEditor.m
//  SEMarkdownEditor
//
//  Created by Brian Nickel on 12/1/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "UITextView+SEMarkdownEditor.h"
#import "../Core/SEMarkdownTextChunks.h"

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
}

@end
