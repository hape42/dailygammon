//
//  InviteDetail.m
//  DailyGammon
//
//  Created by Peter on 06.06.19.
//  Copyright © 2019 Peter Schneider. All rights reserved.
//

#import "InviteDetail.h"
#import "RatingVC.h"
#import "GameLounge.h"
#import "TopPageVC.h"
#import "DbConnect.h"
#import "Player.h"
#import "AppDelegate.h"
#import "Design.h"
#import "iPhoneMenue.h"

@interface InviteDetail ()

@property (nonatomic, strong) UIPickerView *picker;
@property (readwrite, retain, nonatomic) UIView *pickerSammelView;
@property (assign, atomic) CGRect pickerViewFrameSave;

@property (readwrite, retain, nonatomic) NSArray *matchlength;
@property (readwrite, retain, nonatomic) NSArray *timeControl;

@property (assign, atomic) BOOL isMatchLength;
@property (assign, atomic) BOOL isTimeControl;
@property (assign, atomic) int timeControlSelected;
@property (assign, atomic) int matchLengthSelected;

@property (weak, nonatomic) IBOutlet UISegmentedControl *variant;
@property (weak, nonatomic) IBOutlet UIButton *matchLengthButton;
@property (weak, nonatomic) IBOutlet UIButton *timeControlButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *comment;
@property (weak, nonatomic) IBOutlet UITextField *named;
@property (weak, nonatomic) IBOutlet UISwitch *privateMatch;

@property (weak, nonatomic) IBOutlet UIButton *sendMessage;
@property (weak, nonatomic) IBOutlet UIButton *ignorePlayer;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *inviteText;
@property (weak, nonatomic) IBOutlet UILabel *messageTextTitle;
@property (weak, nonatomic) IBOutlet UITextField *messageText;

@property (assign, atomic) BOOL isMessageText;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIView *inviteView;

@property (readwrite, retain, nonatomic) UIButton *topPageButton;
@property (assign, atomic) BOOL loginOk;

@end

@implementation InviteDetail

@synthesize design;
@synthesize playerNummer, playerName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
  
    self.timeControl = [NSArray arrayWithObjects:@"Never",
                        @"Twice a Day (100/+2/15)",
                        @"Once a Day (200/+4/24)",
                        @"Weekday (250/+0/72)",
                        @"Marathon (250/+1/24)",
                        @"Once in 2 days (250/+4/48)",
                        @"Once a Week (250/+0/168)",
                        @"Once a Month (0/+0/750)",
                        nil];
    
    design = [[Design alloc] init];
    
    self.matchLengthButton = [design makeNiceButton:self.matchLengthButton];
    self.timeControlButton = [design makeNiceButton:self.timeControlButton];
    self.inviteButton      = [design makeNiceButton:self.inviteButton];
    self.cancelButton      = [design makeNiceButton:self.cancelButton];
    self.sendMessage       = [design makeNiceButton:self.sendMessage];

    self.isMatchLength = TRUE;
    self.isTimeControl = FALSE;
    
    self.pickerSammelView = [[UIView alloc] initWithFrame:CGRectMake(999, 999, 300, 400)];
    [self.view addSubview:self.pickerSammelView];
    self.pickerViewFrameSave = self.pickerSammelView.frame;

    self.picker.delegate = self;
    self.picker.dataSource = self;

    self.comment.delegate = self;
    self.named.delegate = self;
    self.messageText.delegate = self;

    self.messageView.layer.cornerRadius = 14.0f;
    self.messageView.layer.borderWidth = 1.0f;

    self.inviteText.text = [NSString stringWithFormat:@"Invite %@ to a game of", playerName];
    self.inviteText.adjustsFontSizeToFitWidth = YES;
    self.inviteText.numberOfLines = 0;
    self.inviteText.minimumScaleFactor = 0.5;

    self.messageTextTitle.text = [NSString stringWithFormat:@"Quick message to %@", playerName];
    self.messageTextTitle.adjustsFontSizeToFitWidth = YES;
    self.messageTextTitle.numberOfLines = 0;
    self.messageTextTitle.minimumScaleFactor = 0.5;

    [self.ignorePlayer setTitle:[NSString stringWithFormat:@"Ignore %@", playerName] forState:UIControlStateNormal];

    self.matchLengthSelected = 3;
    self.timeControlSelected = 0;
    
    CGRect frame = CGRectMake(self.privateMatch.frame.origin.x,
                               self.privateMatch.frame.origin.y + 4, 50, 35);
    self.privateMatch.frame = frame;
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1) boardSchema = 4;

    NSMutableDictionary *schemaDict = [design schema:boardSchema];

    [self.privateMatch setTintColor:[schemaDict objectForKey:@"TintColor"]];
    [self.privateMatch setOnTintColor:[schemaDict objectForKey:@"TintColor"]];

    self.messageText.tag = 42;
    
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
    {
        int maxBreite = [UIScreen mainScreen].bounds.size.width;
        frame = self.inviteView.frame;
        frame.origin.x = (maxBreite - self.inviteView.frame.size.width)/2;
        self.inviteView.frame = frame;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    

}

- (void)moreAction
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    iPhoneMenue *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneMenue"];
    [self.navigationController pushViewController:vc animated:NO];
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.isTimeControl)
        return self.timeControl.count;
    if(self.isMatchLength)
        return self.matchlength.count;

    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    if(self.isTimeControl)
    {
        [self.timeControlButton setTitle:self.timeControl[row] forState:UIControlStateNormal];
        self.timeControlSelected = (int)row;
    }
    if(self.isMatchLength)
    {
        NSDictionary *dict = self.matchlength[row];

        [self.matchLengthButton setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
        self.matchLengthSelected = [[dict objectForKey:@"key"]intValue];
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{

    NSString *title;
    UILabel *lblRow = [[UILabel alloc] init] ;
    lblRow.layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
    [lblRow setTextAlignment:NSTextAlignmentCenter];
    lblRow.frame = CGRectMake(25, 0.0f, self.picker.frame.size.width - 50, 44.0f);

    if(self.isTimeControl)
        title = self.timeControl[row];
    if(self.isMatchLength)
    {
        NSDictionary *dict = self.matchlength[row];
        title = [dict objectForKey:@"name"];
    }

    [lblRow setTextColor: [UIColor darkTextColor]];

    [lblRow setText:title];
    lblRow.adjustsFontSizeToFitWidth = YES;
    lblRow.numberOfLines = 0;
    lblRow.minimumScaleFactor = 0.5;

    // Clear the background color to avoid problems with the display.
    [lblRow setBackgroundColor:[UIColor clearColor]];

    return lblRow;

}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (IBAction)matchLengthAction:(id)sender
{
    if(self.pickerSammelView.frame.origin.x != 999) //damit es nicht mehrfach aufgerufen wird
        return;
    
    self.isMatchLength = TRUE;
    self.isTimeControl = FALSE;

    int maxBreite = self.view.bounds.size.width;

    float breite = 300;
    float hoehe = 300;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];

    float x = 0,y = 0;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        x = (maxBreite - breite)/2;
        y = self.matchLengthButton.frame.origin.y + 40;
    }
    else
    {
        x = 10;
        y = 50;
        hoehe = 250;
        breite = 250;
    }
    self.pickerSammelView = [[UIView alloc] initWithFrame:CGRectMake(x,y,breite,hoehe)];

    self.pickerSammelView.backgroundColor = [UIColor whiteColor];
    self.pickerSammelView.layer.borderWidth = 1.0f;
    self.pickerSammelView.layer.cornerRadius = 14.0f;

    self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 50, breite, hoehe-50)];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self.picker selectRow:self.matchLengthSelected inComponent:0 animated:YES];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(closePickerView)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    button.frame = CGRectMake(10.0, 5.0, self.picker.frame.size.width - 20, 30.0);
    design = [[Design alloc] init];
    button = [design makeNiceButton:button];
    
    [self.pickerSammelView addSubview:button];
    
    UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 40.0, self.picker.frame.size.width - 20, 30.0)];
    text.text = @"Select match length";
    [text setTextAlignment:NSTextAlignmentCenter];
    [self.pickerSammelView addSubview:text];

    
    [self.pickerSammelView addSubview:self.picker];
    [self.view addSubview:self.pickerSammelView];
    [UIView commitAnimations];

    [self.picker reloadAllComponents];

}

- (IBAction)timeControlAction:(id)sender
{
    if(self.pickerSammelView.frame.origin.x != 999) //damit es nicht mehrfach aufgerufen wird
        return;

    self.isMatchLength = FALSE;
    self.isTimeControl = TRUE;

    int maxBreite = self.view.bounds.size.width;
    
    float breite = 400;
    float hoehe = 300;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    float x = 0,y = 0;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        x = (maxBreite - breite)/2;
        y = self.timeControlButton.frame.origin.y + 40;
    }
    else
    {
        x = 10;
        y = 50;
        hoehe = 250;
        breite = 250;
    }
    self.pickerSammelView = [[UIView alloc] initWithFrame:CGRectMake(x,y,breite,hoehe)];

    self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 50, breite, hoehe-50)];
    
    self.pickerSammelView.backgroundColor = [UIColor whiteColor];
    self.pickerSammelView.layer.borderWidth = 1.0f;
    self.pickerSammelView.layer.cornerRadius = 14.0f;
    
    self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 50, breite, hoehe-50)];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self.picker selectRow:self.timeControlSelected inComponent:0 animated:YES];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(closePickerView)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    button.frame = CGRectMake(10.0, 5.0, self.picker.frame.size.width - 20, 30.0);
    design = [[Design alloc] init];
    button = [design makeNiceButton:button];
    
    [self.pickerSammelView addSubview:button];
    
    UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 40.0, self.picker.frame.size.width - 20, 30.0)];
    text.text = @"Select time control";
    [text setTextAlignment:NSTextAlignmentCenter];

    [self.pickerSammelView addSubview:text];
    
    [self.pickerSammelView addSubview:self.picker];
    [self.view addSubview:self.pickerSammelView];
    [UIView commitAnimations];
    
    [self.picker reloadAllComponents];

}

-(void)closePickerView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.pickerSammelView.frame = CGRectMake(999, 999, 400, 400);
    [UIView commitAnimations];
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
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn)
    {
        XLog(@"Connection Successful");
    } else
    {
        XLog(@"Connection could not be made");
    }

    [self doInvite];
}
-(void)doInvite
{
    __block NSString *strComment = @"";
    NSString * encodedString = [self.comment.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

    [encodedString enumerateSubstringsInRange:NSMakeRange(0,
                                                          self.comment.text.length)
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
                            3,
                            strPrivate];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/invite/new"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];

    if(conn)
    {
        XLog(@"Connection Successful");
    } else
    {
        XLog(@"Connection could not be made");
    }

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - textField
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    if(textField.tag == 42)
        self.isMessageText = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    [self closePickerView];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    [self.comment endEditing:YES];
    [self.named endEditing:YES];
    
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
        CGRect frame = self.inviteView.frame;
        frame.origin.y = -100;
        self.inviteView.frame = frame;
        XLog(@"keyboardDidShow %f",self.view.frame.origin.y );
}

-(void)keyboardDidHide:(NSNotification *)notification
{
        CGRect frame = self.inviteView.frame;
        frame.origin.y = 0;
        self.inviteView.frame = frame;
        XLog(@"keyboardDidHide %f",self.view.frame.origin.y );
        self.isMessageText = FALSE;
}

- (IBAction)cancelAction:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:TRUE];
}

@end
