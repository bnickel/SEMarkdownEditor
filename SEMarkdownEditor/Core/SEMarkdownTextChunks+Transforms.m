//
//  SEMarkdownTextChunks+Transforms.m
//  Stack Exchange
//
//  Created by Brian Nickel on 2/13/14.
//  Copyright (c) 2014 Stack Exchange. All rights reserved.
//

#import "SEMarkdownTextChunks+Transforms.h"
#import "NSString+SERegularExpressions.h"

const NSInteger SEMarkdownLineLength = 72;

NS_INLINE NSString *PreventAutomaticSpoiler(NSString *text) {
    // TODO: Implement
    return text;
}

NS_INLINE NSString *ProperlyEncoded(NSString *linkDefinition) {
    return [linkDefinition SE_stringByReplacingFirstOccuranceOfPattern:@"^\\s*(.*?)(?:\\s+\"(.+)\")?\\s*\\z" options:0 withBlock:^NSString *(NSArray *matches) {
        NSString *link = [matches[1] SE_stringByReplacingFirstOccuranceOfPattern:@"\\?.*$" options:0 withBlock:^NSString *(NSArray *matches) {
            return [matches[0] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        }];
        link = [[link stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        link = [[[link stringByReplacingOccurrencesOfString:@"'" withString:@"%27"] stringByReplacingOccurrencesOfString:@")" withString:@"%29"] SE_stringByReplacingFirstOccuranceOfPattern:@"\\?.*$" options:0 withBlock:^NSString *(NSArray *matches) {
            return [matches[0] stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
        }];
        
        NSString *title = matches[2];
        
        if (title.length) {
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            title = [[[[[title stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"]
                        stringByReplacingOccurrencesOfString:@"(" withString:@"&#40;"]
                       stringByReplacingOccurrencesOfString:@")" withString:@"&#41"]
                      stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
                     stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
            

        }
        
        return title.length > 0 ? [NSString stringWithFormat:@"%@ \"%@\"", link, title] : link;
    }];
}

@implementation SEMarkdownTextChunks (Transforms)

- (void)toggleCode
{
    BOOL hasTextBefore = [self.before SE_matchesPattern:@"\\S[ ]*\\z" options:0];
    BOOL hasTextAfter = [self.after SE_matchesPattern:@"^[ ]*\\S" options:0];
    
    // Use 'four space' markdown if the selection is on its own
    // line or is multiline.
    if ((!hasTextBefore && !hasTextAfter) || [self.selection SE_matchesPattern:@"\n" options:0]) {
        
        self.before = [self.before SE_stringByReplacingFirstOccuranceOfPattern:@"[ ]{4}\\z" options:0 withBlock:^NSString *(NSArray *matches) {
            self.selection = [matches[0] stringByAppendingString:self.selection];
            return @"";
        }];
        
        NSInteger nLinesBack = 1;
        NSInteger nLinesForward = 1;
        
        if ([self.before SE_matchesPattern:@"(\n|^)(\t|[ ]{4,}).*\n\\z" options:0]) {
            nLinesBack = 0;
        }
        
        if ([self.after SE_matchesPattern:@"^\n(\t|[ ]{4,})" options:0]) {
            nLinesForward = 0;
        }
        
        [self skipLinesBack:nLinesBack forward:nLinesForward findExtraNewlines:NO];
        
        if (!self.selection.length) {
            self.startTag = @"    ";
            self.selection = NSLocalizedString(@"enter code here", nil);
        } else {
            if ([self.selection SE_matchesPattern:@"^[ ]{0,3}\\S" options:NSRegularExpressionAnchorsMatchLines]) {
                if ([self.selection SE_matchesPattern:@"\n" options:0]) {
                    self.selection = [self.selection SE_stringByReplacingPattern:@"^" options:NSRegularExpressionAnchorsMatchLines withTemplate:@"    "];
                } else {
                    // if it's not multiline, do not select the four added spaces; this is more consistent with the doList behavior
                    self.before = [self.before stringByAppendingString:@"    "];
                }
            } else {
                self.selection = [self.selection SE_stringByReplacingPattern:@"^(?:[ ]{4}|[ ]{0,3}\t)" options:NSRegularExpressionAnchorsMatchLines withTemplate:@""];
            }
        }
        
    } else {
        
        // Use backticks (`) to delimit the code block.
        [self trimWhitespaceAndRemove:NO];
        [self findLeft:@"`" andRightTags:@"`"];
        
        if (!self.startTag.length && !self.endTag.length) {
            self.startTag = @"`";
            self.endTag = @"`";
            if (!self.selection.length) {
                self.selection = NSLocalizedString(@"enter code here", nil);
            }
        } else if (self.endTag.length && !self.startTag.length) {
            self.before = [self.before stringByAppendingString:self.endTag];
            self.endTag = @"";
        } else {
            self.startTag = @"";
            self.endTag = @"";
        }
    }
}

- (void)toggleBlockquote
{
    self.selection = [self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"^(\n*)([^\r]+?)(\n*)\\z" options:0 withBlock:^NSString *(NSArray *matches) {
        self.before = [self.before stringByAppendingString:matches[1]];
        self.after = [matches[3] stringByAppendingString:self.after];
        return matches[2];
    }];
    
    self.before = [self.before SE_stringByReplacingFirstOccuranceOfPattern:@"(>[ \t*])\\z" options:0 withBlock:^NSString *(NSArray *matches) {
        self.selection = [matches[1] stringByAppendingString:self.selection];
        return @"";
    }];
    
    self.selection = [self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"^(\\s|>)+\\z" options:0 withTemplate:@""];
    
    if (self.selection.length == 0) {
        self.selection = NSLocalizedString(@"Block quote", nil);
    }

    // The original code uses a regular expression to find out how much of the
    // text *directly before* the selection already was a blockquote:
    
    /*
     if (chunk.before) {
     chunk.before = chunk.before.replace(/\n?$/, "\n");
     }
     chunk.before = chunk.before.replace(/(((\n|^)(\n[ \t]*)*>(.+\n)*.*)+(\n[ \t]*)*$)/,
     function (totalMatch) {
     chunk.startTag = totalMatch;
     return "";
     });
     */
    
    // This comes down to:
    // Go backwards as many lines a possible, such that each line
    //  a) starts with ">", or
    //  b) is almost empty, except for whitespace, or
    //  c) is preceeded by an unbroken chain of non-empty lines
    //     leading up to a line that starts with ">" and at least one more character
    // and in addition
    //  d) at least one line fulfills a)
    //
    // Since this is essentially a backwards-moving regex, it's susceptible to
    // catstrophic backtracking and can cause the browser to hang;
    // see e.g. http://meta.stackoverflow.com/questions/9807.
    //
    // Hence we replaced this by a simple state machine that just goes through the
    // lines and checks for a), b), and c).
    
    NSMutableString *match = [NSMutableString string];
    NSMutableString *leftOver = [NSMutableString string];
    
    if (self.before.length > 0) {
        NSArray *lines = [[self.before SE_stringByReplacingFirstOccuranceOfPattern:@"\n\\z" options:0 withTemplate:@""] componentsSeparatedByString:@"\n"];
        BOOL inChain = NO;
        for (NSString *line in lines) {
            BOOL good = NO;
            inChain = inChain && line.length > 0;        // c) any non-empty line continues the chain
            if ([line SE_matchesPattern:@"^>" options:0]) { // a)
                good = YES;
                if (!inChain && line.length > 1) {       // c) any line that starts with ">" and has at least one more character starts the chain
                    inChain = YES;
                }
            } else if ([line SE_matchesPattern:@"^[ \t]*\\z" options:0]) { // b)
                good = YES;
            } else {
                good = inChain;                   // c) the line is not empty and does not start with ">", so it matches if and only if we're in the chain
            }
            
            if (good) {
                [match appendString:line];
                [match appendString:@"\n"];
            } else {
                [leftOver appendString:match];
                [leftOver appendString:line];
                match = [@"\n" mutableCopy];
            }
        }
        
        if (![match SE_matchesPattern:@"(^|\n)>" options:0]) { // d)
            [leftOver appendString:match];
            match = [@"" mutableCopy];
        }
    }
    
    self.startTag = [match copy];
    self.before = [leftOver copy];
    
    // end of change
    
    if (self.after.length > 0) {
        self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:@"^\n?" options:0 withTemplate:@"\n"];
    }
    
    self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:@"^(((\n|^)(\n[ \t]*)*>(.+\n)*.*)+(\n[ \t]*)*)" options:0 withBlock:^NSString *(NSArray *matches) {
        self.endTag = matches[0];
        return @"";
    }];
    
    if ([self.selection SE_matchesPattern:@"^(?![ ]{0,3}>)" options:NSRegularExpressionAnchorsMatchLines]) {
        [self wrapWithLength:SEMarkdownLineLength - 2];
        self.selection = [self.selection SE_stringByReplacingPattern:@"^" options:NSRegularExpressionAnchorsMatchLines withTemplate:@"> "];
        [self replaceBlanksInTagsUsingBracket:YES];
    } else {
        self.selection = [self.selection SE_stringByReplacingPattern:@"^[ ]{0,3}> ?" options:NSRegularExpressionAnchorsMatchLines withTemplate:@""];
        [self unwrap];
        [self replaceBlanksInTagsUsingBracket:NO];
        
        if (![self.selection SE_matchesPattern:@"^(\n|^)[ ]{0,3}" options:0] && self.startTag.length > 0) {
            self.startTag = [self.startTag SE_stringByReplacingFirstOccuranceOfPattern:@"\n{0,2}\\z" options:0 withTemplate:@"\n\n"];
        }
        
        if (![self.selection SE_matchesPattern:@"\n|^[ ]{0,3}>.*\\z" options:0] && self.endTag.length > 0) {
            self.endTag = [self.endTag SE_stringByReplacingFirstOccuranceOfPattern:@"^\n{0,2}" options:0 withTemplate:@"\n\n"];
        }
    }
    
    self.selection = PreventAutomaticSpoiler(self.selection);
    
    if (![self.selection SE_matchesPattern:@"\n" options:0]) {
        self.selection = [self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"^)(> *)" options:0 withBlock:^NSString *(NSArray *matches) {
            self.startTag = [self.startTag stringByAppendingString:matches[1]];
            return @"";
        }];
    }
}

- (void)replaceBlanksInTagsUsingBracket:(BOOL)useBracket
{
    NSString *replacement = useBracket ? @"> " : @"";
    
    if (self.startTag.length > 0) {
        self.startTag = [self.startTag SE_stringByReplacingFirstOccuranceOfPattern:@"\n((>|\\s)*\n\\z" options:0 withBlock:^NSString *(NSArray *matches) {
            return [NSString stringWithFormat:@"\n%@\n", [matches[1] SE_stringByReplacingPattern:@"^[ ]{0,3}>?[ \t]*$" options:NSRegularExpressionAnchorsMatchLines withTemplate:replacement]];
        }];
    }
    
    if (self.endTag.length > 0) {
        self.endTag = [self.startTag SE_stringByReplacingFirstOccuranceOfPattern:@"^\n((>|\\s)*\n" options:0 withBlock:^NSString *(NSArray *matches) {
            return [NSString stringWithFormat:@"\n%@\n", [matches[1] SE_stringByReplacingPattern:@"^[ ]{0,3}>?[ \t]*$" options:NSRegularExpressionAnchorsMatchLines withTemplate:replacement]];
        }];
    }
};

- (void)toggleItalics
{
    [self doNumberOfStars:1 insertText:NSLocalizedString(@"emphasized text", nil)];
}

- (void)toggleBoldface
{
    [self doNumberOfStars:2 insertText:NSLocalizedString(@"strong text", nil)];
}

- (void)doNumberOfStars:(NSInteger)numberOfStars insertText:(NSString *)insertText
{
    // Get rid of whitespace and fixup newlines.
    [self trimWhitespaceAndRemove:NO];
    self.selection = [self.selection SE_stringByReplacingPattern:@"\n{2,}" options:0 withTemplate:@"\n"];
    
    // Look for stars before and after.  Is the chunk already marked up?
    // note that these regex matches cannot fail
    NSString *starsBefore = [self.before SE_firstOccuranceOfPattern:@"\\**\\z" options:0];
    NSString *starsAfter = [self.after SE_firstOccuranceOfPattern:@"^\\**" options:0];
    
    NSUInteger prevStars = MIN(starsBefore.length, starsAfter.length);
    
    // Remove stars if we have to since the button acts as a toggle.
    if ((prevStars >= numberOfStars) && (prevStars != 2 || numberOfStars != 1)) {
        self.before = [self.before SE_stringByReplacingFirstOccuranceOfPattern:[NSString stringWithFormat:@"[*]{%ld}\\z", (long)numberOfStars] options:0 withTemplate:@""];
        self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:[NSString stringWithFormat:@"^[*]{%ld}", (long)numberOfStars] options:0 withTemplate:@""];
    } else if (!self.selection.length && starsAfter.length) {
        // It's not really clear why this code is necessary.  It just moves
        // some arbitrary stuff around.
        __block NSString *whitespace = @"";
        self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:@"^[*_]*" options:0 withTemplate:@""];
        self.before = [self.before SE_stringByReplacingFirstOccuranceOfPattern:@"(\\s?)\\z" options:0 withBlock:^NSString *(NSArray *matches) {
            whitespace = matches[0];
            return @"";
        }];
        self.before = [self.before stringByAppendingFormat:@"%@%@", starsAfter ?: @"", whitespace];
    } else {
        
        // In most cases, if you don't have any selected text and click the button
        // you'll get a selected, marked up region with the default text inserted.
        if (!self.selection.length && !starsAfter.length) {
            self.selection = insertText;
        }
        
        // Add the true markup.
        NSString *markup = numberOfStars <= 1 ? @"*" : @"**"; // shouldn't the test be = ?
        self.before = [self.before stringByAppendingString:markup];
        self.after = [markup stringByAppendingString:self.after];
    }
}

- (void)toggleLinkWithCreationBlock:(void (^)(SEMarkdownTextChunks *(^)(NSString *)))block
{
    [self toggleLinkWithCreationBlock:block isImage:NO];
}

- (void)toggleImageWithCreationBlock:(void (^)(SEMarkdownTextChunks *(^)(NSString *)))block
{
    [self toggleLinkWithCreationBlock:block isImage:YES];
}

- (void)toggleLinkWithCreationBlock:(void (^)(SEMarkdownTextChunks *(^)(NSString *)))block isImage:(BOOL)isImage
{
    NSParameterAssert(block);
    [self trimWhitespaceAndRemove:NO];
    [self findLeft:@"\\s*!?\\[" andRightTags:@"\\][ ]?(?:\n[ ]*)?(\\[.*?\\])?"];
    if (self.endTag.length > 1 && self.startTag.length > 0) {
        self.startTag = [self.startTag SE_stringByReplacingFirstOccuranceOfPattern:@"!?\\[" options:0 withTemplate:@""];
        self.endTag = @"";
        [self addLinkDefinition:nil];
        return;
    }
    
    self.selection = [NSString stringWithFormat:@"%@%@%@", self.startTag, self.selection, self.endTag];
    self.startTag = @"";
    self.endTag = @"";
    
    if ([self.selection SE_matchesPattern:@"\n\n" options:0]) {
        [self addLinkDefinition:nil];
        return;
    }
    
    SEMarkdownTextChunks *chunks = [self copy];
    
    block(^SEMarkdownTextChunks *(NSString *linkText) {
        
        if (linkText.length == 0) {
            return chunks;
        }
        
        // Fixes common pasting errors.
        linkText = [linkText SE_stringByReplacingFirstOccuranceOfPattern:@"^http:\\/\\/(http?/ftp):\\/\\/" options:0 withTemplate:@"$1://"];
        if (![linkText SE_matchesPattern:@"^(?:https?|ftp):\\/\\/" options:0]) {
            linkText = [@"http://" stringByAppendingString:linkText];
        }
        
        // (                          $1
        //     [^\\]                  anything that's not a backslash
        //     (?:\\\\)*              an even number (this includes zero) of backslashes
        // )
        // (?=                        followed by
        //     [[\]]                  an opening or closing bracket
        // )
        //
        // In other words, a non-escaped bracket. These have to be escaped now to make sure they
        // don't count as the end of the link or similar.
        // Note that the actual bracket has to be a lookahead, because (in case of to subsequent brackets),
        // the bracket in one match may be the "not a backslash" character in the next match, so it
        // should not be consumed by the first match.
        // The "prepend a space and finally remove it" steps makes sure there is a "not a backslash" at the
        // start of the string, so this also works if the selection begins with a bracket. We cannot solve
        // this by anchoring with ^, because in the case that the selection starts with two brackets, this
        // would mean a zero-width match at the start. Since zero-width matches advance the string position,
        // the first bracket could then not act as the "not a backslash" for the second.
        
        chunks.selection = [[[@" " stringByAppendingString:chunks.selection] SE_stringByReplacingPattern:@"([^\\\\](?:\\\\\\\\)*)(?=[[\\]])" options:0 withTemplate:@"$1\\"] substringFromIndex:1];
        
        NSString *linkDefinition = [@" [999]: " stringByAppendingString:ProperlyEncoded(linkText)];
        
        NSInteger linkNumber = [chunks addLinkDefinition:linkDefinition];
        
        chunks.startTag = isImage ? @"![" : @"[";
        chunks.endTag = [NSString stringWithFormat:@"][%ld]", (long)linkNumber];
        
        if (chunks.selection.length == 0) {
            chunks.selection = isImage ? NSLocalizedString(@"enter image description here", nil) : NSLocalizedString(@"enter link description here", nil);
        }
        
        return chunks;
    });
}

- (NSInteger)addLinkDefinition:(NSString *)linkDefinition
{
    __block NSInteger referenceNumber = 0;
    NSMutableDictionary *definitionsToAdd = [NSMutableDictionary dictionary];
    
    // Start with a clean slate by removing all previous link definitions.
    self.before = [self stripLinkDefinitions:definitionsToAdd fromString:self.before];
    self.selection = [self stripLinkDefinitions:definitionsToAdd fromString:self.selection];
    self.after = [self stripLinkDefinitions:definitionsToAdd fromString:self.after];
    
    NSMutableString *definitions = [NSMutableString string];
    
    NSString *pattern = @"(\\[)((?:\\[[^\\]]*\\]|[^\\[\\]])*)(\\][ ]?(?:\n[ ]*)?\\[)(\\d+)(\\])";
    
    void (^addDefinitionNumber)(NSString *) = ^(NSString *definition) {
        referenceNumber ++;
        [definitions appendFormat:@"\n%@", [definition SE_stringByReplacingFirstOccuranceOfPattern:@"^[ ]{0,3}\\[(\\d+)\\]:" options:0 withTemplate:[NSString stringWithFormat:@"  [%ld]:", (long)referenceNumber]]];
    };
    
    // note that
    // a) the recursive call to getLink cannot go infinite, because by definition
    //    of regex, inner is always a proper substring of wholeMatch, and
    // b) more than one level of nesting is neither supported by the regex
    //    nor making a lot of sense (the only use case for nesting is a linked image)
    NSString *(^getLink)(NSArray *);
    __weak __block typeof(getLink) weakGetLink;
    getLink = ^NSString *(NSArray *matches) {
        
        NSString *before = matches[1];
        NSString *inner = [matches[2] SE_stringByReplacingPattern:pattern options:0 withBlock:weakGetLink];
        NSString *afterInner = matches[3];
        NSString *linkId = matches[4];
        NSString *end = matches[5];
        
        if (definitionsToAdd[linkId]) {
            addDefinitionNumber(definitionsToAdd[linkId]);
            return [NSString stringWithFormat:@"%@%@%@%ld%@", before, inner, afterInner, (long)referenceNumber, end];
        }
        
        return matches[0];
    };
    weakGetLink = getLink;
    
    self.before = [self.before SE_stringByReplacingPattern:pattern options:0 withBlock:getLink];
    
    if (linkDefinition) {
        addDefinitionNumber(linkDefinition);
    } else {
        self.selection = [self.selection SE_stringByReplacingPattern:pattern options:0 withBlock:getLink];
    }
    
    NSInteger referenceOut = referenceNumber;
    
    self.after = [self.after SE_stringByReplacingPattern:pattern options:0 withBlock:getLink];
    
    if (self.after.length > 0) {
        self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:@"\n*\\z" options:0 withTemplate:@""];
    }
    
    if (self.after.length == 0) {
        self.selection = [self.selection SE_stringByReplacingFirstOccuranceOfPattern:@"\n*\\z" options:0 withTemplate:@""];
    }
    
    if (definitions.length > 0) {
        self.after = [self.after stringByAppendingFormat:@"\n\n%@", definitions];
    }
    
    return referenceOut;
}

- (NSString *)stripLinkDefinitions:(NSMutableDictionary *)linkDefinitions fromString:(NSString *)string
{
    return [string SE_stringByReplacingPattern:@"^[ ]{0,3}\\[(\\d+)\\]:[ \t]*\n?[ \t]*<?(\\S+?)>?[ \t]*\n?[ \t]*(?:(\n*)[\"(](.+?)[\")][ \t]*)?(?:\n+|$)" options:NSRegularExpressionAnchorsMatchLines withBlock:^NSString *(NSArray *matches) {
        NSString *linkId = matches[1];
        NSString *newLines = matches[3];
        NSString *title = matches[4];
        linkDefinitions[linkId] = [matches[0] SE_stringByReplacingFirstOccuranceOfPattern:@"\\s*\\z" options:0 withTemplate:@""];
        if (newLines.length > 0) {
            linkDefinitions[linkId] = [matches[0] SE_stringByReplacingFirstOccuranceOfPattern:@"[\"(](.+?)[\")]\\z" options:0 withTemplate:@""];
            return [newLines stringByAppendingString:title];
        }
        return @"";
    }];
}

- (void)toggleHeading
{
    // Remove leading/trailing whitespace and reduce internal spaces to single spaces.
    self.selection = [[self.selection SE_stringByReplacingPattern:@"\\s+" options:0 withTemplate:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // If we clicked the button with no selected text, we just
    // make a level 2 hash header around some default text.
    if (self.selection.length == 0) {
        self.startTag = @"## ";
        self.selection = NSLocalizedString(@"Heading", nil);
        self.endTag = @" ##";
        return;
    }
    
    NSInteger headerLevel = 0; // The existing header level of the selected text.
    
    [self findLeft:@"#+[ ]*" andRightTags:@"[ ]*#+"];
    
    // Remove any existing hash heading markdown and save the header level.
    if (self.startTag.length > 0) {
        headerLevel = NSMaxRange([self.startTag rangeOfString:@"#" options:NSBackwardsSearch]);
    }
    self.startTag = @"";
    self.endTag = @"";
    
    // Try to get the current header level by looking for - and = in the line
    // below the selection.
    
    [self findLeft:nil andRightTags:@"\\s?(-+|=+)"];
    if ([self.endTag SE_matchesPattern:@"=+" options:0]) {
        headerLevel = 1;
    }
    if ([self.endTag SE_matchesPattern:@"-+" options:0]) {
        headerLevel = 2;
    }
    
    // Skip to the next line so we can create the header markdown.
    self.startTag = @"";
    self.endTag = @"";
    [self skipLinesBack:1 forward:1 findExtraNewlines:NO];
    
    // We make a level 2 header if there is no current header.
    // If there is a header level, we substract one from the header level.
    // If it's already a level 1 header, it's removed.
    NSInteger headerLevelToCreate = headerLevel == 0 ? 2 : headerLevel - 1;
    
    if (headerLevelToCreate > 0) {
        // The button only creates level 1 and 2 underline headers.
        // Why not have it iterate over hash header levels?  Wouldn't that be easier and cleaner?
        NSString *headerChar = headerLevelToCreate >= 2 ? @"-" : @"=";
        
        NSInteger length = MIN(self.selection.length, SEMarkdownLineLength);
        NSMutableString *endTag = [@"\n" mutableCopy];
        
        while (length--) {
            [endTag appendString:headerChar];
        }
        self.endTag = [endTag copy];
    }
}

- (void)toggleHorizontalRule
{
    self.startTag = @"----------\n";
    self.selection = @"";
    [self skipLinesBack:2 forward:1 findExtraNewlines:YES];
}

- (void)toggleOrderedList
{
    [self toggleListWithNumbers:YES unknown:NO];
}

- (void)toggleUnorderedList
{
    [self toggleListWithNumbers:NO unknown:NO];
}

#define ITEM_PATTERN @"(([ ]{0,3}([*+-]|\\d+[.])[ \t]+.*)(\n.+|\n{2,}([*+-].*|\\d+[.])[ \t]+.*|\n{2,}[ \t]+\\S.*)*)\n*"

- (void)toggleListWithNumbers:(BOOL)hasNumbers unknown:(BOOL)unknownNumberStatus
{
    __block BOOL isNumberedList = hasNumbers;
    __block BOOL unknown = unknownNumberStatus;
    
    NSString *previousItemPattern = @"(\n|^)" ITEM_PATTERN @"\\z";
    NSString *nextItemPattern = @"^\n*" ITEM_PATTERN;
    
    // The default bullet is a dash but others are possible.
    // This has nothing to do with the particular HTML bullet,
    // it's just a markdown bullet.
    __block NSString *bullet = @"-";
    
    // The number in a numbered list.
    __block NSInteger num = 1;
    
    // Get the item prefix - e.g. " 1. " for a numbered list, " - " for a bulleted list.
    NSString *(^getItemPrefix)(id) = ^NSString *(__unused id _){
        if (isNumberedList) {
            return [NSString stringWithFormat:@" %ld. ", (long)num++];
        } else {
            return [NSString stringWithFormat:@" %@ ", bullet];
        }
    };
    
    // Fixes the prefixes of the other list items.
    NSString *(^getPrefixedItem)(NSString *) = ^NSString *(NSString *itemText) {
        
        // The numbering flag is unset when called by autoindent.
        if (unknown) {
            isNumberedList = [itemText SE_matchesPattern:@"^\\s*\\d" options:0];
            unknown = NO;
        }
        
        // Renumber/bullet the list element.
        return [itemText SE_stringByReplacingPattern:@"^[ ]{0,3}([*+-]|\\d+[.])\\s" options:NSRegularExpressionAnchorsMatchLines withBlock:getItemPrefix];
    };
    
    [self findLeft:@"(\n|^)*[ ]{0,3}([*+-]|\\d+[.])\\s+" andRightTags:nil];
    
    if (self.before.length > 0 && ![self.before SE_matchesPattern:@"\n\\z" options:0] && ![self.startTag SE_matchesPattern:@"^\n" options:0]) {
        self.before = [self.before stringByAppendingString:self.startTag];
        self.startTag = @"";
    }
    
    if (self.startTag.length > 0) {
        BOOL hasDigits = [self.startTag SE_matchesPattern:@"\\d+[.]" options:0];
        self.startTag = @"";
        self.selection = [self.selection SE_stringByReplacingPattern:@"\n[ ]{4}" options:0 withTemplate:@"\n"];
        [self unwrap];
        [self skipLinesBack:1 forward:1 findExtraNewlines:NO];
        
        // Have to renumber the bullet points if this is a numbered list.
        if (hasDigits) {
            self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:nextItemPattern options:0 withBlock:^NSString *(NSArray *matches) {
                return getPrefixedItem(matches[0]);
            }];
        }
        
        if ((isNumberedList && hasDigits) || (!isNumberedList && !hasDigits)) {
            return;
        }
    }
    
    __block NSInteger nLinesUp = 1;
    
    self.before = [self.before SE_stringByReplacingFirstOccuranceOfPattern:previousItemPattern options:0 withBlock:^NSString *(NSArray *matches) {
        
        // This was the easiest way to do this.
        [matches[0] SE_stringByReplacingFirstOccuranceOfPattern:@"^\\s*([*+-])" options:0 withBlock:^NSString *(NSArray *matches) {
            bullet = matches[1];
            return @"";
        }];
        
        nLinesUp = [matches[0] SE_matchesPattern:@"[^\n]\n\n[^\n]" options:0] ? 1 : 0;
        return getPrefixedItem(matches[0]);
    }];
    
    if (self.selection.length == 0) {
        self.selection = NSLocalizedString(@"List item", nil);
    }
    
    NSString *prefix = getItemPrefix(nil);
    
    __block NSInteger nLinesDown = 1;
    
    self.after = [self.after SE_stringByReplacingFirstOccuranceOfPattern:nextItemPattern options:0 withBlock:^NSString *(NSArray *matches) {
        nLinesDown = [matches[0] SE_matchesPattern:@"[^\n]\n\n[^\n]" options:0] ? 1 : 0;
        return getPrefixedItem(matches[0]);
    }];
    
    [self trimWhitespaceAndRemove:YES];
    [self skipLinesBack:nLinesUp forward:nLinesDown findExtraNewlines:YES];
    self.startTag = prefix;
    NSString *spaces = [prefix SE_stringByReplacingPattern:@"." options:0 withTemplate:@" "];
    [self wrapWithLength:SEMarkdownLineLength - spaces.length];
    self.selection = [self.selection SE_stringByReplacingPattern:@"\n" options:0 withTemplate:[@"\n" stringByAppendingString:spaces]];
}

@end
