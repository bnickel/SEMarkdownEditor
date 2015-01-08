//
//  NSString+SERegularExpressions.m
//  Stack Exchange
//
//  Created by Brian Nickel on 2/12/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import "NSString+SERegularExpressions.h"

@implementation NSString (SERegularExpressions)

- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)template
{
    NSParameterAssert(template != nil);
    return [self SE_stringByReplacingPattern:pattern options:options withBlock:nil orTemplate:template limit:NSIntegerMax];
}

- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *))block
{
    NSParameterAssert(block != nil);
    return [self SE_stringByReplacingPattern:pattern options:options withBlock:block orTemplate:nil limit:NSIntegerMax];
}

- (NSString *)SE_stringByReplacingFirstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)template
{
    NSParameterAssert(template != nil);
    return [self SE_stringByReplacingPattern:pattern options:options withBlock:nil orTemplate:template limit:1];
}

- (NSString *)SE_stringByReplacingFirstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *))block
{
    NSParameterAssert(block != nil);
    return [self SE_stringByReplacingPattern:pattern options:options withBlock:block orTemplate:nil limit:1];
}

- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *))block orTemplate:(NSString *)template limit:(NSInteger)limit
{
    NSParameterAssert((block && !template) || (template && !block));
    
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    NSAssert(expression != nil, @"Could not parse %@. Error: %@", pattern, error.localizedDescription);
    
    NSMutableString *mutableString = [self mutableCopy];
    NSInteger occurances = 0;
    
    NSInteger offset = 0;
    for (NSTextCheckingResult *result in [expression matchesInString:mutableString options:0 range:NSMakeRange(0, mutableString.length)]) {
        
        NSString *replacementString;
        
        if (template) {
            
            replacementString = [expression replacementStringForResult:result inString:self offset:0 template:template];
            
        } else {
            
            NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:result.numberOfRanges];
            
            for (NSUInteger i = 0; i < result.numberOfRanges; i ++) {
                NSRange subrange = [result rangeAtIndex:i];
                [matches addObject: subrange.location != NSNotFound ? [self substringWithRange:subrange] : @""];
            }
            
            replacementString = block(matches);
        }
        
        
        NSRange resultRange = result.range;
        resultRange.location += offset;
        
        [mutableString replaceCharactersInRange:resultRange withString:replacementString];
        offset += replacementString.length - resultRange.length;
        
        if (++occurances >= limit) {
            break;
        }
    }
    
    return [mutableString copy];
}

- (NSString *)SE_firstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    NSAssert(expression != nil, @"Could not parse %@. Error: %@", pattern, error.localizedDescription);
    NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return result != nil && result.range.location != NSNotFound ? [self substringWithRange:result.range] : nil;
}

- (BOOL)SE_matchesPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSAssert(expression != nil, @"Could not parse %@. Error: %@", pattern, error.localizedDescription);
    NSRange range = [expression rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return range.location != NSNotFound;
}

@end
