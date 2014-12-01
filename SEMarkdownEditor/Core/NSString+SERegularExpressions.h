//
//  NSString+SERegularExpressions.h
//  Stack Exchange
//
//  Created by Brian Nickel on 2/12/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SERegularExpressions)

- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)templateString;
- (NSString *)SE_stringByReplacingPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *matches))block;
- (NSString *)SE_stringByReplacingFirstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)templateString;
- (NSString *)SE_stringByReplacingFirstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withBlock:(NSString *(^)(NSArray *matches))block;
- (NSString *)SE_firstOccuranceOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (BOOL)SE_matchesPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;

@end
