//
//  PlayerDetail.m
//  DailyGammon
//
//  Created by Peter Schneider on 23.03.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "PlayerDetail.h"
#import "DGButton.h"
#import "DGLabel.h"
#import "PlayerLists.h"
#import "Constants.h"
#import "TFHpple.h"
#import "DGRequest.h"
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"
#import "InviteDetail.h"
#import "QuickMessage.h"
#import "Design.h"
#import "PlayerNote.h"

@interface PlayerDetail ()

@property (weak, nonatomic) IBOutlet DGButton *doneButton;
@property (weak, nonatomic) IBOutlet DGLabel *playerName;
@property (weak, nonatomic) IBOutlet DGLabel *realNameLabel;
@property (weak, nonatomic) IBOutlet DGLabel *realName;
@property (weak, nonatomic) IBOutlet DGLabel *locationLabel;
@property (weak, nonatomic) IBOutlet DGLabel *location;
@property (weak, nonatomic) IBOutlet DGLabel *emailLabel;
@property (weak, nonatomic) IBOutlet DGLabel *email;
@property (weak, nonatomic) IBOutlet DGLabel *homepageLabel;
@property (weak, nonatomic) IBOutlet DGLabel *homePage;
@property (weak, nonatomic) IBOutlet DGLabel *commentLabel;
@property (weak, nonatomic) IBOutlet DGLabel *comment;
@property (weak, nonatomic) IBOutlet DGButton *inviteButton;
@property (weak, nonatomic) IBOutlet DGButton *messageButton;

@end

@implementation PlayerDetail

@synthesize userID;
@synthesize playerProfileArray;
@synthesize waitView;
@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    design = [[Design alloc] init];

    [self layoutObjects];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startActivityIndicator: @"Getting User Details data from www.dailygammon.com"];

    [self readDataForPlayer];

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

#pragma mark - layoutObjects
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 5.0;
    float labelWidth = 100;
    float labelHeight = 35;

#pragma mark doneButton autoLayout
    [self.doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.doneButton.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.doneButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.doneButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.doneButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark playerName autoLayout
    [self.playerName setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.playerName.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.playerName.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.playerName.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.playerName.leftAnchor constraintEqualToAnchor:self.doneButton.rightAnchor constant:gap].active = YES;
    
#pragma mark realName autoLayout
    [self.realNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.realNameLabel.topAnchor constraintEqualToAnchor:self.playerName.bottomAnchor constant:gap].active = YES;
    [self.realNameLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.realNameLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.realNameLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.realName setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.realName.topAnchor constraintEqualToAnchor:self.realNameLabel.topAnchor constant:0].active = YES;
    [self.realName.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.realName.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.realName.leftAnchor constraintEqualToAnchor:self.realNameLabel.rightAnchor constant:gap].active = YES;

    self.realName.adjustsFontSizeToFitWidth = YES;
    self.realName.numberOfLines = 0;
    self.realName.minimumScaleFactor = 0.1;

#pragma mark location autoLayout
    [self.locationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.locationLabel.topAnchor constraintEqualToAnchor:self.realName.bottomAnchor constant:gap].active = YES;
    [self.locationLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.locationLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.locationLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.location setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.location.topAnchor constraintEqualToAnchor:self.locationLabel.topAnchor constant:0].active = YES;
    [self.location.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.location.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.location.leftAnchor constraintEqualToAnchor:self.locationLabel.rightAnchor constant:gap].active = YES;

    self.location.adjustsFontSizeToFitWidth = YES;
    self.location.numberOfLines = 0;
    self.location.minimumScaleFactor = 0.1;

#pragma mark email autoLayout
    [self.emailLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.emailLabel.topAnchor constraintEqualToAnchor:self.location.bottomAnchor constant:gap].active = YES;
    [self.emailLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.emailLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.emailLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.email setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.email.topAnchor constraintEqualToAnchor:self.emailLabel.topAnchor constant:0].active = YES;
    [self.email.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.email.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.email.leftAnchor constraintEqualToAnchor:self.emailLabel.rightAnchor constant:gap].active = YES;

    self.email.adjustsFontSizeToFitWidth = YES;
    self.email.numberOfLines = 0;
    self.email.minimumScaleFactor = 0.1;

#pragma mark homePage autoLayout
    [self.homepageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.homepageLabel.topAnchor constraintEqualToAnchor:self.email.bottomAnchor constant:gap].active = YES;
    [self.homepageLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.homepageLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.homepageLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.homePage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.homePage.topAnchor constraintEqualToAnchor:self.homepageLabel.topAnchor constant:0].active = YES;
    [self.homePage.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.homePage.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.homePage.leftAnchor constraintEqualToAnchor:self.homepageLabel.rightAnchor constant:gap].active = YES;

    self.homePage.adjustsFontSizeToFitWidth = YES;
    self.homePage.numberOfLines = 0;
    self.homePage.minimumScaleFactor = 0.1;

#pragma mark comment autoLayout
    [self.commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.commentLabel.topAnchor constraintEqualToAnchor:self.homePage.bottomAnchor constant:gap].active = YES;
    [self.commentLabel.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.commentLabel.widthAnchor constraintEqualToConstant:labelWidth].active = YES;
    [self.commentLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.comment setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.comment.topAnchor constraintEqualToAnchor:self.commentLabel.topAnchor constant:0].active = YES;
    [self.comment.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.comment.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.comment.leftAnchor constraintEqualToAnchor:self.commentLabel.rightAnchor constant:gap].active = YES;

    self.comment.adjustsFontSizeToFitWidth = YES;
    self.comment.numberOfLines = 0;
    self.comment.minimumScaleFactor = 0.1;

#pragma mark inviteButton autoLayout
    [self.inviteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.inviteButton.topAnchor constraintEqualToAnchor:self.commentLabel.bottomAnchor constant:edge].active = YES;
    [self.inviteButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.inviteButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.inviteButton.widthAnchor  constraintEqualToConstant:80].active = YES;

#pragma mark messageButton autoLayout
    [self.messageButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.messageButton.topAnchor constraintEqualToAnchor:self.commentLabel.bottomAnchor constant:edge].active = YES;
    [self.messageButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.messageButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.messageButton.widthAnchor  constraintEqualToConstant:80].active = YES;

#pragma mark historyButton
    UIButton *historyButton = [[UIButton alloc] init];
    historyButton = [design designChatHistoryButton:historyButton];
    [historyButton addTarget:self action:@selector(notYetImplemented) forControlEvents:UIControlEventTouchUpInside];
    historyButton.tag = 1;
    [self.view addSubview:historyButton];

    [historyButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [historyButton.topAnchor constraintEqualToAnchor:self.commentLabel.bottomAnchor constant:edge].active = YES;
    [historyButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [historyButton.widthAnchor constraintEqualToConstant:35].active = YES;
    [historyButton.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:-40].active = YES;

#pragma mark infoButton
    UIButton *infoButton = [[UIButton alloc] init];
    infoButton = [design designSystemImageButton:@"info.circle" button:infoButton];
    [infoButton addTarget:self action:@selector(playerNote:) forControlEvents:UIControlEventTouchUpInside];
    infoButton.tag = 1;
    [self.view addSubview:infoButton];

    [infoButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [infoButton.topAnchor constraintEqualToAnchor:self.commentLabel.bottomAnchor constant:edge].active = YES;
    [infoButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [infoButton.widthAnchor constraintEqualToConstant:35].active = YES;
    [infoButton.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor constant:+40].active = YES;

}
- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)readDataForPlayer
{
    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/user/%@", userID] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            [ self analyzeHTML:result];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;
}

- (void)analyzeHTML:(NSString *)result
{
    playerProfileArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSData *htmlData = [result dataUsingEncoding:NSUnicodeStringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];

    NSArray *elementHeader  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[1]/table[1]/tr/th"];

    for(TFHppleElement *element in elementHeader)
    {
//        XLog(@"th - %@",[element text]);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[element text] forKey:@"name"];
        [playerProfileArray addObject:dict];

    }
    NSArray *elementContent  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[1]/table[1]/tr/td"];

    int index = 0;
    for(TFHppleElement *element in elementContent)
    {
//        XLog(@"td - %@",[element text]);
//        XLog(@"content - %@",[element content]);
//        XLog(@"attributes - %@",[element attributes]);

        NSMutableDictionary *dict = playerProfileArray[index++];
        [dict setValue:[element content] forKey:@"content"];
    }

    NSString *text = @"-";
    for(NSMutableDictionary *dict in playerProfileArray)
    {
        if([[dict objectForKey:@"name"] isEqualToString:@"Real Name"])
            text = [dict valueForKey:@"content"];
    }
    self.realName.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //XLog(@"%@",playerProfileArray);
    text = @"-";
    for(NSMutableDictionary *dict in playerProfileArray)
    {
        if([[dict objectForKey:@"name"] isEqualToString:@"Location"])
            text = [dict valueForKey:@"content"];
    }
    self.location.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    text = @"-";
    for(NSMutableDictionary *dict in playerProfileArray)
    {
        if([[dict objectForKey:@"name"] isEqualToString:@"E-mail"])
            text = [dict valueForKey:@"content"];
    }
    self.email.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if([self isValidEmail:self.email.text])
    {
        UITapGestureRecognizer* mail1LblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mail1LblTapped:)];
        [self.email setUserInteractionEnabled:YES];
        [self.email addGestureRecognizer:mail1LblGesture];
    }

    text = @"-";
    for(NSMutableDictionary *dict in playerProfileArray)
    {
        if([[dict objectForKey:@"name"] isEqualToString:@"Home Page"])
            text = [dict valueForKey:@"content"];
    }
    self.homePage.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if([self isValidURL:self.homePage.text])
    {
        UITapGestureRecognizer* homePageLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homePage1LblTapped:)];
        [self.homePage setUserInteractionEnabled:YES];
        [self.homePage addGestureRecognizer:homePageLblGesture];
    }
    
    text = @"-";
    for(NSMutableDictionary *dict in playerProfileArray)
    {
        if([[dict objectForKey:@"name"] isEqualToString:@"Comment"])
            text = [dict valueForKey:@"content"];
    }
    self.comment.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    elementContent  = [xpathParser searchWithXPathQuery:@"//table[2]/tr[1]/td[2]"];
    
    for(TFHppleElement *element in elementContent)
    {
        for(TFHppleElement *child in element.children )
            self.playerName.text = [child content];
    }

    [self stopActivityIndicator];

}
#pragma mark - email
- (void)mail1LblTapped:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Problem found"
                                      message:[NSString stringWithFormat: @"Normally the email is sent with Apple Mail. There seems to be a problem with Apple Mail. Please select your email program and send the email to %@",self.email.text]
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancelButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        return;
                                    }];

        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
        XLog(@"Fehler: Mail kann nicht versendet werden");
        return;
    }
    else
    {

        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@""];
        NSArray *toRecipients = [NSArray arrayWithObjects:self.email.text, nil];
        [mailer setToRecipients:toRecipients];
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:NULL];

    }
 }
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)isValidEmail:(NSString *)email 
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - Home Page

- (void)homePage1LblTapped:(id)sender
{
    NSURL *URL = [NSURL URLWithString:self.homePage.text];
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }
}

- (BOOL)isValidURL:(NSString *)urlString 
{
    if ([urlString hasPrefix:@"http"])
        return YES;
    else
        return NO;
}

#pragma mark - Invite

- (IBAction)inviteAction:(id)sender 
{
    InviteDetail *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"InviteDetailVC"];
    controller.playerName = self.playerName.text;
    controller.playerNummer = userID;

    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;


}
#pragma mark - Quick message
- (IBAction)messageAction:(id)sender
{
    QuickMessage *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"QuickMessage"];
    controller.playerName = self.playerName.text;
    controller.playerNummer = userID;

    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

#pragma mark - Player Note
- (IBAction)playerNote:(id)sender
{
    PlayerNote *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayerNote"];
    controller.playerName = self.playerName.text;
    controller.playerID = userID;

    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

-(void)notYetImplemented
{
    NSString *title = @"not yet implemented";
    NSString *message = @"comming soon";
       
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle: title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:20.0]
                             range:NSMakeRange(0, title.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]  range:NSMakeRange(0, title.length)];
    [alert setValue:attributedString forKey:@"attributedTitle"];


    alert.view.tintColor = [UIColor blackColor];
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    return;
                                }];
    [alert addAction:okButton];
   [self presentViewController:alert animated:YES completion:nil];
}

@end
