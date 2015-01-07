//
//  NSString+SERegularExpressions.h
//  Stack Exchange
//
//  Created by Brian Nickel on 2/12/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SERegularExpressions)

/**
 @abstract Returns a new string with all matching substrings replaced with the template string.
 @discussion This method is similar to @c -[NSRegularExpression @c stringByReplacingMatchesInString:options:range:withTemplate:] with default matching options over the whole string.  It is also similar to JavaScript's @c String.prototype.replace method with the global flag and a template argument.
 @param pattern The regular expression pattern to compile.
 @param options The matching options to use when creating the regular expression.
 @param templateString The substitution template used when replacing matching instances.
 @return A string with matching regular expressions replaced by the template string.
 @see SE_stringByReplacingFirstOccuranceOfPattern:options:withTemplate:
 */
- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)templateString;

/**
 @abstract Returns a new string with all matching substrings replaced with the values returned by the block.
 @discussion This method is similar to JavaScript's @c String.prototype.replace method with the global flag and a function argument.
 @param pattern The regular expression pattern to compile.
 @param options The matching options to use when creating the regular expression.
 @param block The block to call whenever a match is found. An array of matching groups is passed in starting with the full match.
 @return A string with matching regular expressions replaced by the values returned by the block.
 @see SE_stringByReplacingFirstOccuranceOfPattern:options:withTemplate:
 */
- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *matches))block;

/**
 @abstract Returns a new string with the first matching substring replaced with the template string.
 @see SE_stringByReplacingPattern:options:withTemplate:
 @param pattern The regular expression pattern to compile.
 @param options The matching options to use when creating the regular expression.
 @param templateString The substitution template used when replacing matching instances.
 @return A string with matching regular expressions replaced by the template string.
 */
- (NSString *)SE_stringByReplacingFirstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)templateString;

/**
 @abstract Returns a new string with the first matching substring replaced with the values returned by the block.
 @param pattern The regular expression pattern to compile.
 @param options The matching options to use when creating the regular expression.
 @param block The block to call whenever a match is found. An array of matching groups is passed in starting with the full match.
 @return A string with matching regular expressions replaced by the values returned by the block.
 @see SE_stringByReplacingPattern:options:withBlock:
 */
- (NSString *)SE_stringByReplacingFirstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *matches))block;

/**
 @abstract Returns the first substring matching the pattern or nil if no matches were found.
 @discussion This is a convenience wrapper around @c -[NSRegularExpression @c firstMatchInString:options:range:] with default matching options over the whole string.
 @param pattern The regular expression pattern to compile.
 @param options The matching options to use when creating the regular expression.
 */
- (NSString *)SE_firstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;

/**
 @abstract Returns @c YES if the string matches the pattern with the specified options.
 @discussion This is a convenience wrapper around @c -[NSRegularExpression @c firstMatchInString:options:range:] with default matching options over the whole string.
 @param pattern The regular expression pattern to compile.
 @param options The matching options to use when creating the regular expression.
 */
- (BOOL)SE_matchesPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;

@end
