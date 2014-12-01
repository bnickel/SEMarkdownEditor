//
//  ViewController.m
//  iOS Demo
//
//  Created by Brian Nickel on 12/1/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "ViewController.h"
@import SEMarkdownEditor;

@interface ViewController ()
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
    __block SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleLinkWithCreationBlock:^(SEMarkdownTextChunks *(^complete)(NSString *)) {
        
        [self.textView resignFirstResponder];

        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:@"http://example.com/ \"optional title\"" preferredStyle:UIAlertControllerStyleAlert];
        
        __block UITextField *URLField = nil;
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            URLField = textField;
            textField.keyboardType = UIKeyboardTypeURL;
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.textView becomeFirstResponder];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.textView SE_updateWithTextChunks:complete(URLField.text)];
            [self.textView becomeFirstResponder];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    [self.textView SE_updateWithTextChunks:chunks];
}

@end
