//
//  NSAttributedString+SETokenReplacement.h
//  Stack Exchange
//
//  Created by Brian Nickel on 3/18/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (SETokenReplacement)

/**
 @abstract Replaces occurances of tokens with values from a dictionary.
 @description This method searches through the attributed string for text of the pattern @c {key}.  It then checks the replacements dictionary for the value of the key.  If the value is a @c NSAttributedString, the value replaced the original token and uses the styles from the value.  If the value is an @c NSString the token will be replaced with the value and the value will inherit the token's styles.
 @param replacements A dictionary containing @c NSString keys and values of @c NSString or @c NSAttributedString.
 */
- (void)SE_replaceTokensWithValues:(NSDictionary<NSString *, id> *)replacements;

@end

@interface NSAttributedString (SETokenReplacement)

/**
 @abstract Returns a new attributed string replacing occurances of tokens with values from a dictionary.
 @description This method searches through the attributed string for text of the pattern @c {key}.  It then checks the replacements dictionary for the value of the key.  If the value is a @c NSAttributedString, the value replaced the original token and uses the styles from the value.  If the value is an @c NSString the token will be replaced with the value and the value will inherit the token's styles.
 @param replacements A dictionary containing @c NSString keys and values of @c NSString or @c NSAttributedString.
 @returns A new @c NSAttributedString with the substitutions.
 */
- (NSAttributedString *)SE_attributedStringByReplacingTokensWithValues:(NSDictionary<NSString *, id> *)replacements;

@end

@interface NSMutableString (SETokenReplacement)

/**
 @abstract Replaces occurances of tokens with values from a dictionary.
 @description This method searches through the string for text of the pattern @c {key}.  It then checks the replacements dictionary for the value of the key.
 @param replacements A dictionary containing @c NSString keys and @c NSString values.
 */
- (void)SE_replaceTokensWithValues:(NSDictionary<NSString *, id> *)replacements;

@end

@interface NSString (SETokenReplacement)

/**
 @abstract Returns a new string replacing occurances of tokens with values from a dictionary.
 @description This method searches through the string for text of the pattern @c {key}.  It then checks the replacements dictionary for the value of the key.
 @param replacements A dictionary containing @c NSString keys and @c NSString values.
 @returns A new @c NSString with the substitutions.
 */
- (NSString *)SE_stringByReplacingTokensWithValues:(NSDictionary<NSString *, id> *)replacements;

/**
 @abstract Returns a new attributed string replacing occurances of tokens with values from a dictionary.
 @description This method creates a new attributed string with no styling and searches through the attributed string for text of the pattern @c {key}.  It then checks the replacements dictionary for the value of the key.  If the value is a @c NSAttributedString, the value replaced the original token and uses the styles from the value.  If the value is an @c NSString the token will be replaced with the value and the value will have no styling.
 @param replacements A dictionary containing @c NSString keys and values of @c NSString or @c NSAttributedString.
 @returns A new @c NSAttributedString with the substitutions.
 */
- (NSAttributedString *)SE_attributedStringByReplacingTokensWithValues:(NSDictionary<NSString *, id> *)replacements;

@end

NS_ASSUME_NONNULL_END
