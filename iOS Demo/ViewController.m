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
@property (nonatomic, assign) CGFloat keyboardInset;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
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
    [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"Bold", nil)];
}

- (IBAction)toggleItalics:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleItalics];
    [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"Italic", nil)];
}

- (IBAction)toggleCode:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleCode];
    [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"Code", nil)];
}

- (IBAction)toggleOrderedList:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    [chunks toggleOrderedList];
    [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"Ordered List", nil)];
}

- (IBAction)toggleLink:(id)sender
{
    SEMarkdownTextChunks *chunks = [self.textView SE_textChunksFromSelection];
    
    if ([chunks removeLinkOrImage]) {
        
        [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"Remove Link", nil)];
        
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
        [self.textView SE_updateWithTextChunks:chunks actionName:NSLocalizedString(@"Link", nil)];
    }
    
    [self.textView becomeFirstResponder];
}

- (CGFloat)keyboardInsetFromUserInfo:(NSDictionary *)userInfo
{
    id boxedFrame = userInfo[UIKeyboardFrameEndUserInfoKey];
    if (boxedFrame && self.view.window && self.textView) {
        CGRect frame = [boxedFrame CGRectValue];
        return CGRectGetHeight(self.textView.frame) - CGRectGetMinY(frame);
    } else {
        return 0;
    }
}

- (void)setKeyboardInset:(CGFloat)keyboardInset
{
    if (_keyboardInset != keyboardInset) {
        CGFloat delta = keyboardInset - _keyboardInset;
        _keyboardInset = keyboardInset;
        
        UIEdgeInsets contentInset = self.textView.contentInset;
        contentInset.bottom += delta;
        self.textView.contentInset = contentInset;
        
        UIEdgeInsets indicatorInsets = self.textView.scrollIndicatorInsets;
        indicatorInsets.bottom += delta;
        self.textView.scrollIndicatorInsets = indicatorInsets;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"Show: %@", notification.userInfo);
    self.keyboardInset = [self keyboardInsetFromUserInfo:notification.userInfo];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    self.keyboardInset = [self keyboardInsetFromUserInfo:notification.userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardInset = [self keyboardInsetFromUserInfo:notification.userInfo];
}

@end
