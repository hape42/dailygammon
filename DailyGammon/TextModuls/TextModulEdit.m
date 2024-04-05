//
//  TextModulEdit.m
//  DailyGammon
//
//  Created by Peter Schneider on 05.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "TextModulEdit.h"
#import "DGButton.h"
#import "Design.h"

@interface TextModulEdit ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *shortTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *shortText;
@property (weak, nonatomic) IBOutlet UILabel *longTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *longText;
@property (weak, nonatomic) IBOutlet DGButton *saveButton;
@property (weak, nonatomic) IBOutlet DGButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;

@end

@implementation TextModulEdit

@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];

    design = [[Design alloc] init];

    [self layoutObjects];
}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
    float buttonWidth = 80.0;
    float buttonHight = 35;

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.header.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.header.centerXAnchor   constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;

#pragma mark hide keyboard Button

    self.keyboardButton = [design designKeyBoardDownButton:self.keyboardButton];
    [self.keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];

    [self.keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.keyboardButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    [self.keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.keyboardButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.keyboardButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark saveButton
    [self.saveButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.saveButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    [self.saveButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.saveButton.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;
    [self.saveButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

#pragma mark cancelButton
    [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.cancelButton.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;
    [self.cancelButton.leftAnchor constraintEqualToAnchor:self.saveButton.rightAnchor constant:gap].active = YES;

#pragma mark shortText
    [self.shortTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.shortTextLabel.topAnchor constraintEqualToAnchor:self.header.bottomAnchor constant:gap].active = YES;
    [self.shortTextLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.shortTextLabel.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;
    [self.shortTextLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.shortText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.shortText.topAnchor constraintEqualToAnchor:self.header.bottomAnchor constant:gap].active = YES;
    [self.shortText.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.shortText.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.shortText.leftAnchor constraintEqualToAnchor:self.saveButton.rightAnchor constant:gap].active = YES;

#pragma mark shortText
    [self.longTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.longTextLabel.centerYAnchor constraintEqualToAnchor:self.longText.centerYAnchor constant:0].active = YES;
    [self.longTextLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.longTextLabel.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;
    [self.longTextLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.longText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.longText.topAnchor constraintEqualToAnchor:self.shortText.bottomAnchor constant:gap].active = YES;
    [self.longText.bottomAnchor constraintEqualToAnchor:self.keyboardButton.topAnchor constant:-gap].active = YES;
    [self.longText.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.longText.leftAnchor constraintEqualToAnchor:self.longTextLabel.rightAnchor constant:gap].active = YES;

}
#pragma mark - textView delegates
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.view endEditing:YES];

    return YES;
}

@end
