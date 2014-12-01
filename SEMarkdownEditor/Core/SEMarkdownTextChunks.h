//
//  SEMarkdownTextChunks.h
//  Stack Exchange
//
//  Created by Brian Nickel on 2/13/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEMarkdownTextChunks : NSObject<NSCopying>

- (instancetype)initWithText:(NSString *)text selection:(NSRange)selection;
- (NSString *)textWithSelection:(out NSRangePointer)selectedRange;

@property (nonatomic) NSString *before;
@property (nonatomic) NSString *startTag;
@property (nonatomic) NSString *selection;
@property (nonatomic) NSString *endTag;
@property (nonatomic) NSString *after;
- (void)trimWhitespaceAndRemove:(BOOL)remove;
- (void)findLeft:(NSString *)startExpr andRightTags:(NSString *)endExpr;
- (void)skipLinesBack:(NSInteger)nLinesBefore forward:(NSInteger)nLinesAfter findExtraNewlines:(BOOL)findExtraNewlines;

- (void)wrapWithLength:(NSInteger)length;
- (void)unwrap;

@end
