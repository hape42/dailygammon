//
//  InviteDetail.m
//  DailyGammon
//
//  Created by Peter on 06.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "InviteDetail.h"
#import "RatingVC.h"
#import "TopPageCV.h"
#import "DbConnect.h"
#import "Player.h"
#import "AppDelegate.h"
#import "Design.h"
#import <SafariServices/SafariServices.h>
#import "DGButton.h"
#import "PlayerLists.h"

@interface InviteDetail ()


@property (weak, nonatomic) IBOutlet UILabel *inviteText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *variant;

@property (weak, nonatomic) IBOutlet UILabel *matchLengthLabel;
@property (weak, nonatomic) IBOutlet DGButton *matchLengthButton;

@property (weak, nonatomic) IBOutlet UILabel *timeControlLabel;
@property (weak, nonatomic) IBOutlet DGButton *timeControlButton;

@property (weak, nonatomic) IBOutlet UILabel *privatMatchLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privateMatch;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UITextField *comment;

@property (weak, nonatomic) IBOutlet UILabel *namedLabel;
@property (weak, nonatomic) IBOutlet UITextField *named;

@property (weak, nonatomic) IBOutlet DGButton *inviteButton;
@property (weak, nonatomic) IBOutlet DGButton *cancelButton;

@property (assign, atomic) BOOL isMessageText;

@property (assign, atomic) BOOL loginOk;

@property (readwrite, retain, nonatomic) NSArray *matchlength;
@property (readwrite, retain, nonatomic) NSArray *timeControl;

@property (assign, atomic) int timeControlSelected;
@property (assign, atomic) int matchLengthSelected;

@end

@implementation InviteDetail

@synthesize design;
@synthesize playerNummer, playerName;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self layoutObjects];

    self.matchlength = @[
        @{@"name": @"1", @"key": @"1"},
        @{@"name": @"3", @"key": @"3"},
        @{@"name": @"5", @"key": @"5"},
        @{@"name": @"7", @"key": @"7"},
        @{@"name": @"9", @"key": @"9"},
        @{@"name": @"11", @"key": @"11"},
        @{@"name": @"13", @"key": @"13"},
        @{@"name": @"15", @"key": @"15"},
        @{@"name": @"17", @"key": @"17"},
        @{@"name": @"19", @"key": @"19"},
        @{@"name": @"21", @"key": @"21"},
        @{@"name": @"23", @"key": @"23"},
        @{@"name": @"25", @"key": @"25"},
        @{@"name": @"Cubeless Money", @"key": @"-1"},
        @{@"name": @"Money", @"key": @"-2"}
    ];
    NSMutableArray  *menuLengthArray = [[NSMutableArray alloc] initWithCapacity:3];
    int i = 0;
    for(NSDictionary *dict in self.matchlength)
    {
        [menuLengthArray addObject:[UIAction actionWithTitle:[dict objectForKey:@"name"]
                                                 image:nil
                                            identifier:[NSString stringWithFormat:@"%d",i++]
                                               handler:^(__kindof UIAction* _Nonnull action) {
            [self.matchLengthButton setTitle:[dict objectForKey:@"name"] forState: UIControlStateNormal];
            self.matchLengthSelected = [[dict objectForKey:@"key"]intValue];
        }]];
    }
    
    self.matchLengthButton.menu = [UIMenu menuWithChildren:menuLengthArray];
    self.matchLengthButton.showsMenuAsPrimaryAction = YES;

    self.timeControl = [NSArray arrayWithObjects:@"Never",
                        @"Twice a Day (100/+2/15)",
                        @"Once a Day (200/+4/24)",
                        @"Weekday (250/+0/72)",
                        @"Marathon (250/+1/24)",
                        @"Once in 2 days (250/+4/48)",
                        @"Once a Week (250/+0/168)",
                        @"Once a Month (0/+0/750)",
                        nil];
    
    NSMutableArray  *menuTimeArray = [[NSMutableArray alloc] initWithCapacity:3];
    i = 0;
    for(NSString *text in self.timeControl)
    {
        [menuTimeArray addObject:[UIAction actionWithTitle:text
                                                 image:nil
                                            identifier:[NSString stringWithFormat:@"%d",i]
                                               handler:^(__kindof UIAction* _Nonnull action) {
            [self.timeControlButton setTitle:text forState: UIControlStateNormal];
            self.timeControlSelected = i;
        }]];
        i++;
    }
    
    self.timeControlButton.menu = [UIMenu menuWithChildren:menuTimeArray];
    self.timeControlButton.showsMenuAsPrimaryAction = YES;

    design = [[Design alloc] init];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        
    self.comment.delegate = self;
    self.named.delegate = self;
    
    self.inviteText.text = [NSString stringWithFormat:@"Invite %@ to a game of", playerName];
    self.inviteText.adjustsFontSizeToFitWidth = YES;
    self.inviteText.numberOfLines = 0;
    self.inviteText.minimumScaleFactor = 0.5;
    self.inviteText.textColor = [design schemaColor];
        
    self.privateMatch = [design makeNiceSwitch:self.privateMatch];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    self.matchLengthSelected = 5; // der Wert !
    self.timeControlSelected = 0; // der Array Index !
    
}

#pragma mark - layoutObjects
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
    float labelWidth = 150;
    float labelHeight = 35;
    
#pragma mark inviteText autoLayout
    [self.inviteText setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.inviteText.bottomAnchor constraintEqualToAnchor:self.variant.topAnchor constant:-edge].active = YES;
    [self.inviteText.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.inviteText.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.inviteText.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    
#pragma mark variant autoLayout
    [self.variant setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.variant.bottomAnchor constraintEqualToAnchor:self.matchLengthLabel.topAnchor constant:-gap].active = YES;
    [self.variant.widthAnchor constraintEqualToConstant:250].active = YES;
    [self.variant.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;

#pragma mark matchLength autoLayout
    [self.matchLengthLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.matchLengthLabel.bottomAnchor constraintEqualToAnchor:self.timeControlLabel.topAnchor constant:-gap].active = YES;
    [self.matchLengthLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.matchLengthLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.matchLengthLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.matchLengthButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.matchLengthButton.topAnchor constraintEqualToAnchor:self.matchLengthLabel.topAnchor constant:0].active = YES;
    [self.matchLengthButton.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.matchLengthButton.widthAnchor constraintGreaterThanOrEqualToConstant:80].active = YES;
    [self.matchLengthButton.leftAnchor constraintEqualToAnchor:self.matchLengthLabel.rightAnchor constant:gap].active = YES;

#pragma mark timeControl autoLayout
    [self.timeControlLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.timeControlLabel.bottomAnchor constraintEqualToAnchor:self.privatMatchLabel.topAnchor constant:-gap].active = YES;
    [self.timeControlLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.timeControlLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.timeControlLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.timeControlButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.timeControlButton.topAnchor constraintEqualToAnchor:self.timeControlLabel.topAnchor constant:0].active = YES;
    [self.timeControlButton.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.timeControlButton.widthAnchor constraintGreaterThanOrEqualToConstant:80].active = YES;
    [self.timeControlButton.leftAnchor constraintEqualToAnchor:self.timeControlLabel.rightAnchor constant:gap].active = YES;

#pragma mark privateMatch autoLayout
    [self.privatMatchLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.privatMatchLabel.bottomAnchor constraintEqualToAnchor:self.commentLabel.topAnchor constant:-gap].active = YES;
    [self.privatMatchLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.privatMatchLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.privatMatchLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.privateMatch setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.privateMatch.topAnchor constraintEqualToAnchor:self.privatMatchLabel.topAnchor constant:0].active = YES;
    [self.privateMatch.leftAnchor constraintEqualToAnchor:self.privatMatchLabel.rightAnchor constant:gap].active = YES;

#pragma mark comment autoLayout
    [self.commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.commentLabel.bottomAnchor constraintEqualToAnchor:self.namedLabel.topAnchor constant:-gap].active = YES;
    [self.commentLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.commentLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.commentLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.comment setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.comment.topAnchor constraintEqualToAnchor:self.commentLabel.topAnchor constant:0].active = YES;
    [self.comment.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.comment.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.comment.leftAnchor constraintEqualToAnchor:self.commentLabel.rightAnchor constant:gap].active = YES;

#pragma mark named autoLayout
    [self.namedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.namedLabel.bottomAnchor constraintEqualToAnchor:self.inviteButton.topAnchor constant:-gap].active = YES;
    [self.namedLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.namedLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.namedLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.named setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.named.topAnchor constraintEqualToAnchor:self.namedLabel.topAnchor constant:0].active = YES;
    [self.named.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.named.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.named.leftAnchor constraintEqualToAnchor:self.timeControlLabel.rightAnchor constant:gap].active = YES;

#pragma mark inviteButton autoLayout
    [self.inviteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.inviteButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    [self.inviteButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.inviteButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.inviteButton.widthAnchor  constraintEqualToConstant:80].active = YES;

#pragma mark cancelButton autoLayout
    [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.inviteButton.topAnchor constant:0].active = YES;
    [self.cancelButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.cancelButton.widthAnchor  constraintEqualToConstant:80].active = YES;

}

- (IBAction)inviteAction:(id)sender
{
    self.loginOk = FALSE;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    NSString *post = [NSString stringWithFormat:@"login=%@&password=%@",userName,userPassword];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://dailygammon.com/bg/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

    [self doInvite];
}
-(void)doInvite
{
    __block NSString *strComment = @"";
    NSString * encodedString = [self.comment.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
 //   NSString * encodedString = self.comment.text;
    [encodedString enumerateSubstringsInRange:NSMakeRange(0,
                                                          encodedString.length)
                                      options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         
         //NSLog(@"substring: %@ substringRange: %@, enclosingRange %@", substring, NSStringFromRange(substringRange), NSStringFromRange(enclosingRange));
         if([substring isEqualToString:@"‘"])
             strComment = [NSString stringWithFormat:@"%@%@",strComment, @"'"];
         else if([substring isEqualToString:@"„"])
             strComment = [NSString stringWithFormat:@"%@%@",strComment, @"?"];
         else if([substring isEqualToString:@"“"])
             strComment = [NSString stringWithFormat:@"%@%@",strComment, @"?"];
         else
             strComment = [NSString stringWithFormat:@"%@%@",strComment, substring];
         
     }];
    
    __block NSString *strNamend = @"";
    [self.named.text enumerateSubstringsInRange:NSMakeRange(0,
                                                            self.named.text.length)
                                        options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
     {
         
         //NSLog(@"substring: %@ substringRange: %@, enclosingRange %@", substring, NSStringFromRange(substringRange), NSStringFromRange(enclosingRange));
         if([substring isEqualToString:@"‘"])
             strNamend = [NSString stringWithFormat:@"%@%@",strNamend, @"'"];
         else if([substring isEqualToString:@"„"])
             strNamend = [NSString stringWithFormat:@"%@%@",strNamend, @"?"];
         else if([substring isEqualToString:@"“"])
             strNamend = [NSString stringWithFormat:@"%@%@",strNamend, @"?"];
         else
             strNamend = [NSString stringWithFormat:@"%@%@",strNamend, substring];
         
     }];
    
    NSString *strPrivate = @"";
    if(self.privateMatch.on)
    {
        strPrivate = @"@private=private";
    }
    NSString *postString = [NSString stringWithFormat:@"player=%@&variant=%ld&length=%d&comment=%@&name=%@&time_control=%d%@",
                            playerNummer,
                            self.variant.selectedSegmentIndex + 1,
                            self.matchLengthSelected,
                            strComment,
                            strNamend,
                            self.timeControlSelected,
                            strPrivate];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/invite/new"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Invitation"
                                 message:@"Your invitation was sent."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            [self dismissViewControllerAnimated:YES completion:nil];
        else
            [self.navigationController popViewControllerAnimated:TRUE];

                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - textField
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    if(textField.tag == 42)
        self.isMessageText = TRUE;
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{

    [self.comment endEditing:YES];
    [self.named endEditing:YES];
    
    return YES;
}


- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
