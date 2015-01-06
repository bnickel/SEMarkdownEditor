SEMarkdownEditor
================

SEMarkdownEditor is a port of [Pagedown's Markdown.Editor.js](https://code.google.com/p/pagedown/source/browse/Markdown.Editor.js) transformation logic to Objective-C.  While this does not provide rendering capabilities, it does allow you to create a full-fledged markdown toolbar for your `UITextView` similar to what you would see on StackExchange sites.

Example
-------

Performing any transformation is a matter of getting the text and selection information from your `UITextView`, performing a transformation and updating the text view with the new text and selected region:

```objc
- (IBAction)toggleBoldface:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleBoldface];
    [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"markdown.boldface", @"Boldface")];
}
```

```swift
@IBAction func toggleBoldface(sender:AnyObject) {
	let chunks = textView.SE_textChunksFromSelection()
	chunks.toggleBoldface()
	textView.SE_updateWithTextChunks(chunks, actionName:NSLocalizedString("markdown.boldface", comment: "Boldface"))
}
```

Demo
----

The project contains an iOS demo with a simple toolbar demonstrating how to wire features to a toolbar.  Open the project in Xcode 6 or later and run the **iOS Demo** target.

Installation
------------

```ruby
pod 'SEMarkdownEditor'
```
