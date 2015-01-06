//
//  ViewController.m
//  iOS Demo
//
//  Created by Brian Nickel on 12/1/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "ViewController.h"
@import SEMarkdownEditor;

@interface ViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *markdownToolbar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UINib nibWithNibName:@"MarkdownToolbar" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil];
    self.textView.inputAccessoryView = self.markdownToolbar;
    [self.textView becomeFirstResponder];
}

- (IBAction)undo:(id)sender
{
    [self.textView.undoManager undo];
}

- (IBAction)toggleBoldface:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleBoldface];
    [self.textView SE_updateWithTextChunks:chunks];
}

- (IBAction)toggleItalics:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleItalics];
    [self.textView SE_updateWithTextChunks:chunks];
}

- (IBAction)toggleCode:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleCode];
    [self.textView SE_updateWithTextChunks:chunks];
}

- (IBAction)toggleBlockquote:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleBlockquote];
    [self.textView SE_updateWithTextChunks:chunks];
}

- (IBAction)toggleLink:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    
    if ([chunks removeLinkOrImage]) {
        
        [self.textView SE_updateWithTextChunks:chunks];
        
    } else {
    
        [self.textView resignFirstResponder];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Link", nil) message:@"http://example.com/ \"optional title\"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeURL;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
        [chunks addLink:[alertView textFieldAtIndex:0].text];
        [self.textView SE_updateWithTextChunks:chunks];
    }
    
    [self.textView becomeFirstResponder];
}

@end
