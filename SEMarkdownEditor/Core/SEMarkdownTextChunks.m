//
//  SEMarkdownTextChunks.m
//  Stack Exchange
//
//  Created by Brian Nickel on 2/13/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import "SEMarkdownTextChunks.h"
#import <SEStringUtilities/SEStringUtilities.h>

@implementation SEMarkdownTextChunks

- (instancetype)initWithText:(NSString *)text selection:(NSRange)selection
{
    self = [super init];
    if (self) {
        _before = [text substringToIndex:selection.location];
        _startTag = @"";
        _selection = [text substringWithRange:selection];
        _endTag = @"";
        _after = [text substringFromIndex:selection.location + selection.length];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SEMarkdownTextChunks *chunk = [[SEMarkdownTextChunks alloc] init];
    chunk.before = [self.before copy];
    chunk.startTag = [self.startTag copy];
    chunk.selection = [self.selection copy];
    chunk.endTag = [self.endTag copy];
    chunk.after = [self.after copy];
    return chunk;
}

- (void)trimWhitespaceAndRemove:(BOOL)remove
{
    if (remove) {
        self.selection = [self.selection stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        self.selection = [[self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"^([\\s\r\n]*)" options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
            self.before = [self.before stringByAppendingString:matches[0]];
            return @"";
        }] SE_stringByReplacingFirstOccuranceOfPattern:@"([\\s\r\n]*)\\z" options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
            self.after = [matches[0] stringByAppendingString:self.after];
            return @"";
        }];
    }
}

- (void)findLeft:(NSString *)startExpr andRightTags:(NSString *)endExpr
{
    if (startExpr) {
        
        self.before = [self.before SE_stringByReplacingPattern:[startExpr stringByAppendingString:@"$"] options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
            self.startTag = [self.startTag stringByAppendingString:matches[0]];
            return @"";
        }];
        
        self.selection = [self.selection SE_stringByReplacingPattern:[@"^" stringByAppendingString:startExpr] options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
            self.startTag = [self.startTag stringByAppendingString:matches[0]];
            return @"";
        }];
    }
    
    if (endExpr) {
        
        self.selection = [self.selection SE_stringByReplacingPattern:[endExpr stringByAppendingString:@"$"] options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
            self.endTag = [self.endTag stringByAppendingString:matches[0]];
            return @"";
        }];
        
        self.after = [self.after SE_stringByReplacingPattern:[@"^" stringByAppendingString:endExpr] options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
            self.endTag = [self.endTag stringByAppendingString:matches[0]];
            return @"";
        }];
    }
}

- (void)skipLinesBack:(NSInteger)nLinesBefore forward:(NSInteger)nLinesAfter findExtraNewlines:(BOOL)findExtraNewlines
{
    nLinesBefore ++;
    nLinesAfter ++;
    
    self.selection = [self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"^\n*" options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
        self.startTag = [self.startTag stringByAppendingString:matches[0]];
        return @"";
    }];
    
    self.selection = [self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"\n*\\z" options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
        self.endTag = [self.endTag stringByAppendingString:matches[0]];
        return @"";
    }];
    
    self.startTag = [self.startTag SE_stringByReplacingFirstOccuranceOfPattern:@"^\n*" options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
        self.before = [self.before stringByAppendingString:matches[0]];
        return @"";
    }];
    
    self.endTag = [self.endTag SE_stringByReplacingFirstOccuranceOfPattern:@"\n*\\z" options:0 withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
        self.after = [self.after stringByAppendingString:matches[0]];
        return @"";
    }];
    
    if (self.before.length) {
        
        NSMutableString *regexText = [@"" mutableCopy];
        NSMutableString *replacementText = [@"" mutableCopy];
        
        while (nLinesBefore--) {
            [regexText appendString:@"\n?"];
            [replacementText appendString:@"\n"];
        }
        
        if (findExtraNewlines) {
            [regexText appendString:@"\n*"];
        }
        [regexText appendString:@"\\z"];
        self.before = [self.before SE_stringByReplacingFirstOccuranceOfPattern:regexText options:0 withTemplate:replacementText];
    }
    
    if (self.after.length) {
        
        NSMutableString *regexText = [@"^" mutableCopy];
        NSMutableString *replacementText = [@"" mutableCopy];
        
        while (nLinesAfter--) {
            [regexText appendString:@"\\n?"];
            [replacementText appendString:@"\n"];
        }
        if (findExtraNewlines) {
            [regexText appendString:@"\\n*"];
        }
        self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:regexText options:0 withTemplate:replacementText];
    }
}

- (NSString *)textWithSelection:(out NSRangePointer)selectedRange
{
    NSMutableString *text = [[NSMutableString alloc] init];
    [text appendString:self.before];
    [text appendString:self.startTag];
    if (selectedRange) {
        *selectedRange = NSMakeRange(text.length, self.selection.length);
    }
    [text appendString:self.selection];
    [text appendString:self.endTag];
    [text appendString:self.after];
    return [text copy];
}

// The markdown symbols - 4 spaces = code, > = blockquote, etc.
#define PREFIXES  @"(?:\\s{4,}|\\s*>|\\s*-\\s+|\\s*\\d+\\.|=|\\+|-|_|\\*|#|\\s*\\[[^\n]]+\\]:)"

- (void)wrapWithLength:(NSInteger)length
{
    [self unwrap];
    
    NSString *pattern = [NSString stringWithFormat:@"(.{1,%ld})( +|$\\n?)", (long)length];
    
    self.selection = [[self.selection SE_stringByReplacingPattern:pattern options:NSRegularExpressionAnchorsMatchLines withBlock:^NSString * _Nonnull(NSArray<NSString *> * _Nonnull matches, NSRange range, NSString * _Nonnull string) {
        if ([matches[0] SE_matchesPattern:@"^" PREFIXES options:0]) {
            return matches[0];
        }
        return [matches[1] stringByAppendingString:@"\n"];
    }] SE_stringByReplacingFirstOccuranceOfPattern:@"\\s+\\z" options:0 withTemplate:@""];
}

// Remove markdown symbols from the chunk selection.
- (void)unwrap
{
    self.selection = [self.selection SE_stringByReplacingPattern:@"([^\\n])\\n(?!(\\n|" PREFIXES "))" options:0 withTemplate:@"$1 $2"];
}

@end
