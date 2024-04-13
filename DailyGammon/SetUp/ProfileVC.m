//
//  ProfileVC.m
//  DailyGammon
//
//  Created by Peter Schneider on 11.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "ProfileVC.h"
#import "DGButton.h"
#import "Design.h"
#import "AppDelegate.h"
#import "TFHpple.h"
#import "DGRequest.h"

@interface ProfileVC ()

@property (weak, nonatomic) IBOutlet UILabel *header;

@property (weak, nonatomic) IBOutlet DGButton *saveButton;
@property (weak, nonatomic) IBOutlet DGButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;

@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *realName;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextView *location;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextView *email;

@property (weak, nonatomic) IBOutlet UILabel *homePageLabel;
@property (weak, nonatomic) IBOutlet UITextView *homePage;

@property (strong, nonatomic) IBOutlet UIView *commentLabel;
@property (weak, nonatomic) IBOutlet UITextView *comment;

@end

@implementation ProfileVC

@synthesize design;
@synthesize profileArray;
@synthesize waitView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    design = [[Design alloc] init];

    [self layoutObjects];
    
    [self readPublicProfile];
    
    return;
}

#pragma mark - WaitView

- (void)startActivityIndicator:(NSString *)text
{
    if(!waitView)
    {
        waitView = [[WaitView alloc]initWithText:text];
    }
    else
    {
        waitView.messageText = text;
    }
    [waitView showInView:self.view];

}

- (void)stopActivityIndicator
{
    [waitView dismiss];
}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
    float labelWidth = 100.0;

    float buttonWidth = 80.0;
    float buttonHight = 35.0;

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.header.topAnchor     constraintEqualToAnchor:safe.topAnchor     constant:edge].active = YES;
    [self.header.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;

#pragma mark hide keyboard Button

    self.keyboardButton = [design designKeyBoardDownButton:self.keyboardButton];
    [self.keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];

    [self.keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.keyboardButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-gap].active = YES;
    [self.keyboardButton.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                        constant:-edge].active = YES;
    [self.keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.keyboardButton.widthAnchor  constraintEqualToConstant:40].active = YES;

#pragma mark saveButton
    [self.saveButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.saveButton.topAnchor    constraintEqualToAnchor:self.keyboardButton.topAnchor constant:0].active = YES;
    [self.saveButton.leftAnchor   constraintEqualToAnchor:safe.leftAnchor               constant:edge].active = YES;
    [self.saveButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.saveButton.widthAnchor  constraintEqualToConstant:buttonWidth].active = YES;

#pragma mark cancelButton
    [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.cancelButton.topAnchor    constraintEqualToAnchor:self.keyboardButton.topAnchor constant:0].active = YES;
    [self.cancelButton.leftAnchor   constraintEqualToAnchor:self.saveButton.rightAnchor   constant:gap].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.cancelButton.widthAnchor  constraintEqualToConstant:buttonWidth].active = YES;

#pragma mark realName
    [self.realNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.realNameLabel.topAnchor    constraintEqualToAnchor:self.header.bottomAnchor constant:gap].active = YES;
    [self.realNameLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor        constant:edge].active = YES;
    [self.realNameLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.realNameLabel.widthAnchor  constraintEqualToConstant:labelWidth].active = YES;

    [self.realName setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.realName.topAnchor    constraintEqualToAnchor:self.header.bottomAnchor          constant:gap].active = YES;
    [self.realName.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                constant:-edge].active = YES;
    [self.realName.leftAnchor   constraintEqualToAnchor:self.realNameLabel.rightAnchor constant:gap].active = YES;
    [self.realName.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

#pragma mark location
    [self.locationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.locationLabel.topAnchor    constraintEqualToAnchor:self.realName.bottomAnchor constant:gap].active = YES;
    [self.locationLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor        constant:edge].active = YES;
    [self.locationLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.locationLabel.widthAnchor  constraintEqualToConstant:labelWidth].active = YES;

    [self.location setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.location.topAnchor    constraintEqualToAnchor:self.realName.bottomAnchor          constant:gap].active = YES;
    [self.location.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                constant:-edge].active = YES;
    [self.location.leftAnchor   constraintEqualToAnchor:self.locationLabel.rightAnchor constant:gap].active = YES;
    [self.location.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

#pragma mark email
    [self.emailLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.emailLabel.topAnchor    constraintEqualToAnchor:self.location.bottomAnchor constant:gap].active = YES;
    [self.emailLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor        constant:edge].active = YES;
    [self.emailLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.emailLabel.widthAnchor  constraintEqualToConstant:labelWidth].active = YES;

    [self.email setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.email.topAnchor    constraintEqualToAnchor:self.location.bottomAnchor          constant:gap].active = YES;
    [self.email.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                constant:-edge].active = YES;
    [self.email.leftAnchor   constraintEqualToAnchor:self.emailLabel.rightAnchor constant:gap].active = YES;
    [self.email.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

#pragma mark homePage
    [self.homePageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.homePageLabel.topAnchor    constraintEqualToAnchor:self.email.bottomAnchor constant:gap].active = YES;
    [self.homePageLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor        constant:edge].active = YES;
    [self.homePageLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.homePageLabel.widthAnchor  constraintEqualToConstant:labelWidth].active = YES;

    [self.homePage setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.homePage.topAnchor    constraintEqualToAnchor:self.email.bottomAnchor          constant:gap].active = YES;
    [self.homePage.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                constant:-edge].active = YES;
    [self.homePage.leftAnchor   constraintEqualToAnchor:self.homePageLabel.rightAnchor constant:gap].active = YES;
    [self.homePage.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

#pragma mark comment
    [self.commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.commentLabel.topAnchor    constraintEqualToAnchor:self.homePage.bottomAnchor constant:gap].active = YES;
    [self.commentLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor        constant:edge].active = YES;
    [self.commentLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.commentLabel.widthAnchor  constraintEqualToConstant:labelWidth].active = YES;

    [self.comment setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.comment.topAnchor    constraintEqualToAnchor:self.homePage.bottomAnchor          constant:gap].active = YES;
    [self.comment.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                constant:-edge].active = YES;
    [self.comment.leftAnchor   constraintEqualToAnchor:self.commentLabel.rightAnchor constant:gap].active = YES;
    [self.comment.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

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
- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Hpple

- (IBAction)saveAction:(id)sender
{
    NSString *postString = [NSString stringWithFormat:@"name=%@",self.realName.text];
    postString = [NSString stringWithFormat:@"%@&where=%@",postString, self.location.text];
    postString = [NSString stringWithFormat:@"%@&mail=%@",postString, self.email.text];
    postString = [NSString stringWithFormat:@"%@&home=%@",postString, self.homePage.text];
    postString = [NSString stringWithFormat:@"%@&comment=%@",postString, self.comment.text];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dailygammon.com/bg/profile/pub"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

    [self dismissViewControllerAnimated:YES completion:nil];

}


-(void)readPublicProfile
{
    profileArray = [[NSMutableArray alloc]initWithCapacity:5];
    [self startActivityIndicator: @"Getting Public Profile data from www.dailygammon.com"];

    DGRequest *request = [[DGRequest alloc] initWithString:@"http://dailygammon.com/bg/profile" completionHandler:^(BOOL success, NSError *error, NSString *result)
    {
        if (success)
        {
            [self analyzeHTML:result];
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    request = nil;
    
}

- (void)analyzeHTML:(NSString *)result
{
    
    NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//form[2]/table[1]/tr/td"];
    
    for(TFHppleElement *element in elements)
    {
        for(TFHppleElement *child in [element children])
        {
            NSDictionary *dict = [child attributes];

            if([dict objectForKey:@"value"] != nil)
            {
                [profileArray addObject:[dict objectForKey:@"value"]];
                XLog(@"%@",[dict objectForKey:@"value"]);

            }
        }
    }
    if(profileArray.count == 5)
    {
        self.realName.text = profileArray[0];
        self.location.text = profileArray[1];
        self.email.text    = profileArray[2];
        self.homePage.text = profileArray[3];
        self.comment.text  = profileArray[4];
    }
    
    [self stopActivityIndicator];

    return;
}

@end
