//
//  NSAttributedString+SETokenReplacement.m
//  Stack Exchange
//
//  Created by Brian Nickel on 3/18/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import "NSAttributedString+SETokenReplacement.h"

static void SEEnumerateTokenReplacements(NSString *originalString, NSDictionary<NSString *, id> *replacements, void(^block)(NSRange range, id replacement)) {
    
    originalString = [originalString copy];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"\\{(\\w+)\\}" options:0 error:NULL];
    
    __block NSInteger offset = 0;
    
    [expression enumerateMatchesInString:originalString options:0 range:NSMakeRange(0, originalString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSString *key = [originalString substringWithRange:[result rangeAtIndex:1]];
        
        id replacement = replacements[key];
        if (!replacement) {
            return;
        }
        
        NSRange range = [result range];
        range.location += offset;
        offset += [replacement length];
        offset -= range.length;
        
        block(range, replacement);
    }];
}

@implementation NSMutableAttributedString (SETokenReplacement)

- (void)SE_replaceTokensWithValues:(NSDictionary<NSString *,id> *)replacements
{
    SEEnumerateTokenReplacements(self.string, replacements, ^(NSRange range, id replacement) {
        if ([replacement isKindOfClass:[NSAttributedString class]]) {
            [self replaceCharactersInRange:range withAttributedString:replacement];
        } else {
            [self replaceCharactersInRange:range withString:[replacement description]];
        }
    });
}

@end

@implementation NSAttributedString (SETokenReplacement)

- (NSAttributedString *)SE_attributedStringByReplacingTokensWithValues:(NSDictionary<NSString *,id> *)replacements
{
    NSMutableAttributedString *mutableString = [self mutableCopy];
    [mutableString SE_replaceTokensWithValues:replacements];
    return [mutableString copy];
}

@end

@implementation NSMutableString (SETokenReplacement)

- (void)SE_replaceTokensWithValues:(NSDictionary<NSString *,id> *)replacements
{
    SEEnumerateTokenReplacements(self, replacements, ^(NSRange range, id replacement) {
        [self replaceCharactersInRange:range withString:[replacement description]];
    });
}

@end

@implementation NSString (SETokenReplacement)

- (NSString *)SE_stringByReplacingTokensWithValues:(NSDictionary<NSString *,id> *)replacements
{
    NSMutableString *mutableString = [self mutableCopy];
    [mutableString SE_replaceTokensWithValues:replacements];
    return [mutableString copy];
}

- (NSAttributedString *)SE_attributedStringByReplacingTokensWithValues:(NSDictionary<NSString *,id> *)replacements
{
    return [[[NSAttributedString alloc] initWithString:self] SE_attributedStringByReplacingTokensWithValues:replacements];
}

@end
