SEStringUtilities
=================

SEStringUtilities provide a handful of useful string functions used in Stack Exchange.app.

`NSAttributedString+SETokenReplacement`
---------------------------------------

Categories on `NSString` and `NSAttributedString` that allow you to do string templating in a clear and localizable way. Similar to Mustache but for small strings and with attributed string support:

```objc
NSAttributedString *username = ...;
NSString *creationDate = ...;
label.attributedText =
    [NSLocalizedString(@"- Asked by {username} on {creationDate}", nil)
     SE_attributedStringByReplacingTokensWithValues:NSDictionaryOfVariableBindings(username, creationDate)];
```

```swift
let username:NSAttributedString = ...
let creationDate:String = ...
label.attributedText =
    NSLocalizedString("- Asked by {username} on {creationDate}", comment:"").
    SE_attributedStringByReplacingTokensWithValues({"username": username, "creationDate": creationDate})
```

In these examples `username` is an attributed string using its own styling and `creationDate` is a string inheriting its styling from the parent attributed string.

`NSString+SERegularExpressions`
-------------------------------

A category on `NSString` providing functionality similar to JavaScript's `String.prototype.replace`.

`-[NSString SE_stringByReplacingPattern:options:withTemplate:]` is similar to `-[NSRegularExpression stringByReplacingMatchesInString:options:range:withTemplate:]` but a little terser since it takes ownership of creating the regular expression and assumes some default values.

`-[NSString SE_stringByReplacingPattern:options:withBlock:]` on the other hand adds new functionality in that you can easily provide your own complex transformations for the contents of the block. `SEMarkdownEditor` uses this for complex operations including [this gnarly recursive transform](https://github.com/bnickel/SEMarkdownEditor/blob/v0.2.0/SEMarkdownEditor/Core/SEMarkdownTextChunks%2BTransforms.m#L503).

Both methods have a `ReplacingFirstOccuranceOfPattern` variant which limits the change to the first match.

Installation
------------

```ruby
pod 'SEStringUtilities'
```
