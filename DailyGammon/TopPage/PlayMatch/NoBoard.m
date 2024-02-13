//
//  NoBoard.m
//  DailyGammon
//
/*
 During a game html pages keep coming up that do not contain a board.

 I had initially tried to handle everything in a routine. But this routine "showMatch" has grown more and more to handle all special cases.

 This routine is hardly maintainable.

 I now try to handle everything in the "noBoard". The change is large and therefore unfortunately also susceptible to errors or to overlook something.

 The outsourcing to "noBoard" is also a very good opportunity to streamline "PlayMatch" and" iPhonePlayMatch", which will eventually make it easier to merge the two "playMatch".


 Translated with www.DeepL.com/Translator (free version)
 */
 
//  Created by Peter Schneider on 31.03.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "NoBoard.h"
#import <WebKit/WebKit.h>
#import "Design.h"
#import "TFHpple.h"
#import "PlayMatch.h"
#import "iPhonePlayMatch.h"
#import "Preferences.h"
#import "Rating.h"
#import "LoginVC.h"
#import "TopPageCV.h"
#import "AppDelegate.h"
#import "DbConnect.h"
#import "RatingVC.h"
#import "Player.h"
#import "Tools.h"
#import <SafariServices/SafariServices.h>
#import "About.h"
#import "DGButton.h"
#import "PlayerLists.h"
#import "Constants.h"
#import "DGRequest.h"
#import "GameLounge.h"
#import "DGLabel.h"

@interface NoBoard ()

@property (readwrite, retain, nonatomic) DGButton *topPageButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation NoBoard

@synthesize boardDict;

@synthesize design, preferences, rating, tools;
@synthesize waitView;
@synthesize menueView;

@synthesize finishedMatchChat, finishedmatchChatViewFrame, isFinishedMatch;
@synthesize quickmessageChat, quickmessageChatViewFrame, isQuickmessage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    design = [[Design alloc] init];
    preferences = [[Preferences alloc] init];
    rating = [[Rating alloc] init];
    tools = [[Tools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDidHide:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:oneFingerTap];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    else
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
    [self reDrawHeader];
    [self analyze];
}

-(void) reDrawHeader
{
//    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
//        [self.view addSubview:[self makeHeader]];

    self.moreButton.tintColor = [UIColor colorNamed:@"ColorSwitch"];

}

-(void)analyze
{
#pragma mark finishedMatch
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    if( finishedMatchDict != nil)
    {
        [self finishedMatch];
        return;
    }
#pragma mark TopPage
    if([[self.boardDict objectForKey:@"TopPage"] length] != 0)
    {
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"iPad" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
#pragma mark telegramm message
    if([[self.boardDict objectForKey:@"message"] length] != 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:[self.boardDict objectForKey:@"message"]
                                     message:[self.boardDict objectForKey:@"chat"]
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"NEXT"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
                                      }];

        [alert addAction:yesButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
#pragma mark messageSent
    if([[self.boardDict objectForKey:@"messageSent"] length] != 0)
    {
        // just do nothing, go ahead
        [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
        return;
    }
#pragma mark DailyGammon Backups
    if([[self.boardDict objectForKey:@"Backups"] length] != 0)
    {

        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"DailyGammon Backups"
                                     message:@"DailyGammon is sleeping -- SHH!!\n\nCome back in half an hour or so when the daily backups are done, and your games will be here waiting. Gwan! Scoot!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        exit(0);
                                     }];
 
        [alert addAction:okButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
#pragma mark You have received the following quick message from
    if([[self.boardDict objectForKey:@"quickMessage"] length] != 0)
    {
        [self quickMessage];
        return;
    }
#pragma mark invite
    NSMutableDictionary *inviteDict = [self.boardDict objectForKey:@"inviteDict"] ;
    if( inviteDict != nil)
    {
        [self invite];
        return;
    }
#pragma mark There has been an internal error.
    if([[self.boardDict objectForKey:@"internal error"] length] != 0)
    {
        [self internalError];
        return;
    }

#pragma mark unknown HTML found
    [self unknownHTML];

}

#pragma mark - back to playMatch

-(void)playMatch:(NSString *)matchLink
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        PlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"PlayMatch"];
        vc.matchLink = matchLink;
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        iPhonePlayMatch *vc = [app.activeStoryBoard  instantiateViewControllerWithIdentifier:@"iPhonePlayMatch"];
        vc.matchLink = matchLink;
        [self.navigationController pushViewController:vc animated:NO];
    }
    return;
}
#pragma mark - unknown HTML

-(void)unknownHTML
{
    if([ [self.boardDict objectForKey:@"htmlString"] isEqualToString:@""])
    {
        XLog(@"---------> empty htmlString");
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"iPad" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    int y = 10;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        y = 70;
    DGLabel *label  = [[DGLabel alloc] initWithFrame:CGRectMake(10, y, 250, 30)];
    label.textColor = [UIColor redColor];
    [label setFont:[UIFont boldSystemFontOfSize: label.font.pointSize]];
    label.text = @"unknown HTML Page found";

    DGButton *sendHTML = [[DGButton alloc] initWithFrame:CGRectMake(270,y, 300, 30)];
    [sendHTML setTitle:@"send unkonwn HTML to support" forState: UIControlStateNormal];
    [sendHTML addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];

    y += 40;
    WKWebView *htmlView = [[WKWebView alloc] initWithFrame:CGRectMake(10, y, self.view.bounds.size.width - 20,  self.view.bounds.size.height - 110)];
    [htmlView loadHTMLString:[self.boardDict objectForKey:@"htmlString"] baseURL:nil];

    [self.view addSubview:label];
    [self.view addSubview:sendHTML];
    [self.view addSubview:htmlView];

}
#pragma mark - Support Email
- (IBAction)sendEmail:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Problem found"
                                      message:@"Normally the email is sent with Apple Mail. There seems to be a problem with Apple Mail. Please select your email program and send a screenshot of the problem to DG@hape42.de"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancelButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
                                        return;
                                    }];

        [alert addAction:cancelButton];
        alert.view.tag = ALERT_VIEW_TAG;
        [self presentViewController:alert animated:YES completion:nil];
        XLog(@"Fehler: Mail kann nicht versendet werden");
        return;
    }
    NSString *betreff = [NSString stringWithFormat:@"found unknown HTML"];
    
    NSString *emailText = [self.boardDict objectForKey:@"htmlString"];
    
    
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSArray *toSupport = [NSArray arrayWithObjects:@"dg@hape42.de",nil];
    
    [emailController setToRecipients:toSupport];
    [emailController setSubject:betreff];
    [emailController setMessageBody:emailText isHTML:YES];
    
    NSString *dictPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    dictPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"boardDict.txt"];
    NSError *error;

    [[NSString stringWithFormat:@"%@",self.boardDict] writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSData *myData = [NSData dataWithContentsOfFile:dictPath];
    [emailController addAttachmentData:myData mimeType:@"text/plain" fileName:@"boardDict.txt"];

    [self presentViewController:emailController animated:YES completion:NULL];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        XLog(@"Fehler MFMailComposeViewController: %@", error);
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - finishedMatch
- (void)finishedMatch
{
    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    NSString *href = @"";

    for(NSDictionary *dict in [finishedMatchDict objectForKey:@"attributes"])
    {
        href = [dict objectForKey:@"action"];
    }
    isFinishedMatch = YES;
    int edge = 10;
    int gap = 10;
    int x = 50;
    int y = edge;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        y = 70;

    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(x, y, self.view.bounds.size.width - 150 - edge,  self.view.bounds.size.height - y - edge)];
    
    infoView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    y = 0;
    UILabel * matchName = [[UILabel alloc] initWithFrame:CGRectMake(0, y, infoView.layer.frame.size.width , 60)];
    matchName.text = [finishedMatchDict objectForKey:@"matchName"];
    matchName.textAlignment = NSTextAlignmentCenter;

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[finishedMatchDict objectForKey:@"matchName"]];
    [attr addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:40.0]
                  range:NSMakeRange(0, [attr length])];
    [matchName setAttributedText:attr];
    matchName.adjustsFontSizeToFitWidth = YES;
    matchName.numberOfLines = 0;
    matchName.minimumScaleFactor = 0.5;
    matchName.adjustsFontSizeToFitWidth = YES;
    [infoView addSubview:matchName];
    
    NSString *htmlString = [self.boardDict objectForKey:@"htmlString"];
    NSString *winnerText = [finishedMatchDict objectForKey:@"winnerName"];
    if([htmlString containsString:@"Predicted"])
        winnerText = [NSString stringWithFormat:@"(Predicted result) %@", winnerText];
    y += matchName.frame.size.height;
    UILabel * winner = [[UILabel alloc] initWithFrame:CGRectMake(0, y, infoView.layer.frame.size.width , 60)];
    winner.textAlignment = NSTextAlignmentLeft;
    attr = [[NSMutableAttributedString alloc] initWithString:winnerText];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:30.0]
                 range:NSMakeRange(0, [attr length])];
    [winner setAttributedText:attr];
    winner.adjustsFontSizeToFitWidth = YES;
    winner.numberOfLines = 0;
    winner.minimumScaleFactor = 0.5;
    winner.adjustsFontSizeToFitWidth = YES;
    [infoView addSubview:winner];

    y += winner.frame.size.height;
    UILabel * length = [[UILabel alloc] initWithFrame:CGRectMake(0, y, infoView.layer.frame.size.width, 30)];
    length.textAlignment = NSTextAlignmentLeft;
    NSArray *lengthArray = [finishedMatchDict objectForKey:@"matchLength"];
    length.text = [NSString stringWithFormat:@"%@ %@",lengthArray[0], lengthArray[1]];
    [infoView addSubview:length];

    NSArray *playerArray = [finishedMatchDict objectForKey:@"matchPlayer"];
    NSArray *playerLinkArray = [finishedMatchDict objectForKey:@"href"];

    y += length.frame.size.height;
    UILabel * player1Name  = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 150, 30)];
    UILabel * player1Score = [[UILabel alloc] initWithFrame:CGRectMake(player1Name.layer.frame.origin.x +  player1Name.layer.frame.size.width + gap, y , 100, 30)];
    player1Name.textAlignment = NSTextAlignmentLeft;
    player1Name.text = playerArray[0];
    [infoView addSubview:player1Name];
    
    DGButton *buttonPlayer1 = [[DGButton alloc] initWithFrame:CGRectMake(player1Name.frame.origin.x, player1Name.frame.origin.y, player1Name.frame.size.width , player1Name.frame.size.height )] ;
    [buttonPlayer1 setTitle:playerArray[0] forState: UIControlStateNormal];
    [buttonPlayer1.layer setValue:playerArray[0] forKey:@"name"];
    [buttonPlayer1 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonPlayer1];

    player1Score.textAlignment = NSTextAlignmentRight;
    player1Score.text = playerArray[1];
    [infoView addSubview:player1Score];

    y += player1Name.frame.size.height + 10;

    UILabel * player2Name  = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 150, 30)];
    UILabel * player2Score = [[UILabel alloc] initWithFrame:CGRectMake(player2Name.layer.frame.origin.x +  player2Name.layer.frame.size.width + gap, y , 100, 30)];
    player2Name.textAlignment = NSTextAlignmentLeft;
    player2Name.text = playerArray[2];
    [infoView addSubview:player2Name];
    
    DGButton *buttonPlayer2 = [[DGButton alloc] initWithFrame:CGRectMake(player2Name.frame.origin.x, player2Name.frame.origin.y, player2Name.frame.size.width , player2Name.frame.size.height )] ;
    [buttonPlayer2 setTitle:playerArray[2] forState: UIControlStateNormal];
    [buttonPlayer2.layer setValue:playerArray[2] forKey:@"name"];
    [buttonPlayer2 addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:buttonPlayer2];

    player2Score.textAlignment = NSTextAlignmentRight;
    player2Score.text = playerArray[3];
    [infoView addSubview:player2Score];

    y += player2Name.frame.size.height;

    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    if([chatArray[0] containsString:@"chat"])
    {
        // Calculate maximum window height
        float height = infoView.frame.size.height - y - 35 - gap;
        XLog(@"with chat");
        finishedMatchChat  = [[UITextView alloc] initWithFrame:CGRectMake(10, y, infoView.layer.frame.size.width - 20, MIN(250, height) )];
        finishedmatchChatViewFrame = finishedMatchChat.frame;
        finishedMatchChat.textAlignment = NSTextAlignmentLeft;
        NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
        NSString *chatString = @"";
        for( NSString *chatZeile in chatArray)
        {
            if(![chatZeile containsString:@"You may chat with"])
                chatString = [NSString stringWithFormat:@"%@ %@", chatString, chatZeile];
        }
        finishedMatchChat.text = chatString;
        finishedMatchChat.editable = YES;
        [finishedMatchChat setDelegate:self];
        finishedMatchChat.tag = 1000;
        [finishedMatchChat setFont:[UIFont systemFontOfSize:20]];
        [infoView addSubview:finishedMatchChat];

        y += finishedMatchChat.frame.size.height + gap;

    }
    else
    {
        XLog(@"no chat, just a message");
        UILabel *chatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, infoView.layer.frame.size.width , 60)];
        chatLabel.text = chatArray[0];
        chatLabel.adjustsFontSizeToFitWidth = YES;
        chatLabel.numberOfLines = 0;
        chatLabel.minimumScaleFactor = 0.1;
        [infoView addSubview:chatLabel];
        y += chatLabel.frame.size.height + gap;

    }
    NSString *nextButtonText = @"Next Game";
    if([[finishedMatchDict objectForKey:@"NextButton"] isEqualToString:@"Next"])
        nextButtonText = @"Next";
 
    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(50,y, 100, 35)];
    [buttonNext setTitle:nextButtonText forState: UIControlStateNormal];
    [buttonNext addTarget:self action:@selector(actionNextFinishedMatch:) forControlEvents:UIControlEventTouchUpInside];
    [buttonNext.layer setValue:href forKey:@"href"];
    [buttonNext.layer setValue:finishedMatchChat.text forKey:@"chat"];

    [infoView addSubview:buttonNext];
 
    DGButton *buttonToTop = [[DGButton alloc] initWithFrame:CGRectMake(50 + 100 + 50, y, 100, 35)];
    [buttonToTop setTitle:@"To Top" forState: UIControlStateNormal];
    [buttonToTop addTarget:self action:@selector(actionToTopFinishedMatch:) forControlEvents:UIControlEventTouchUpInside];
    [buttonToTop.layer setValue:href forKey:@"href"];
    [buttonToTop.layer setValue:finishedMatchChat.text forKey:@"chat"];
    [infoView addSubview:buttonToTop];

    [self.view addSubview:infoView];
    return;
}

- (void)player:(UIButton*)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    vc.name   = (NSString *)[sender.layer valueForKey:@"name"];

    [self.navigationController pushViewController:vc animated:NO];

}

#pragma mark There has been an internal error.

- (void)internalError

{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"There has been an internal error."
                                 message:@" The error has been logged and the administrators will be alerted. Our apologies.\nThis is a message from the server. The app did not cause this. This is usually not a big deal and you can just keep playing."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"TopPage"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        TopPageCV *vc = [[UIStoryboard storyboardWithName:@"iPad" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];
        [self.navigationController pushViewController:vc animated:NO];
                                 }];

    [alert addAction:okButton];
    alert.view.tag = ALERT_VIEW_TAG;

    alert = [design makeBackgroundColor:alert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark - invite
-(void)invite
{
    if([[self.boardDict objectForKey:@"Invite"] length] != 0)
    {
        NSMutableDictionary *inviteDict = [self.boardDict objectForKey:@"inviteDict"] ;
        NSMutableArray *inviteArray = [inviteDict objectForKey:@"inviteDetails"];
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Message"
                                     message:inviteArray[1]
                                     preferredStyle:UIAlertControllerStyleAlert];
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",inviteArray[0],inviteArray[1]]];
        [message addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:15.0]
                        range:NSMakeRange(0, [message length])];
        [alert setValue:message forKey:@"attributedMessage"];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"Accept"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       NSMutableDictionary * acceptDict = [inviteDict objectForKey:@"AcceptButton"];
                                       NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@?submit=Accept%%20Invitation&action=accept",
                                                                               [acceptDict objectForKey:@"action"]]];
                                       
                                       NSError *error = nil;
                                       NSStringEncoding encoding = 0;
                                       NSString *returnString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                                                           usedEncoding:&encoding
                                                                                                  error:&error]; // this line accepts the invitation
            //TODO:Synchronous URL loading of http://dailygammon.com/bg/invite/455161?submit=Accept%20Invitation&action=accept should not occur on this application's main thread as it may lead to UI unresponsiveness. Please switch to an asynchronous networking API such as URLSession.
                                       [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];

                                   }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Decline"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       NSMutableDictionary * acceptDict = [inviteDict objectForKey:@"DeclineButton"];
                                       NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@?submit=Decline%%20Invitation&action=decline",
                                                                               [acceptDict objectForKey:@"action"]]];
                                       
                                       NSError *error = nil;
                                       NSStringEncoding encoding = 0;
                                       NSString *returnString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                                                           usedEncoding:&encoding
                                                                                                  error:&error]; // this line declines the invitation
            //TODO:Synchronous URL loading of http://dailygammon.com/bg/invite/455161?submit=Decline%20Invitation&action=decline should not occur on this application's main thread as it may lead to UI unresponsiveness. Please switch to an asynchronous networking API such as URLSession.
                                       [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
                                   }];
        
        UIAlertAction* webButton = [UIAlertAction
                                    actionWithTitle:@"Go to Website"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/nextgame"]];
                                        if ([SFSafariViewController class] != nil) {
                                            SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
                                            [self presentViewController:sfvc animated:YES completion:nil];
                                        } else {
                                            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
                                        }
                                                TopPageCV *vc = [[UIStoryboard storyboardWithName:@"iPad" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

                                                [self.navigationController pushViewController:vc animated:NO];

                                    }];
        
        [alert addAction:okButton];
        [alert addAction:noButton];
        [alert addAction:webButton];
        alert.view.tag = ALERT_VIEW_TAG;

        [self presentViewController:alert animated:YES completion:nil];
    }

}
#pragma mark - quickMessage

-(void) quickMessage
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[self.boardDict objectForKey:@"quickMessage"]
                                 message:[self.boardDict objectForKey:@"chat"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"NEXT"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self playMatch:[NSString stringWithFormat:@"/bg/nextgame?submit=Next"]];
                                }];
    UIAlertAction* answerButton = [UIAlertAction
                                actionWithTitle:@"Answer"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    self->isQuickmessage = YES;
                                    int gap = 5;
                                    int edge = 5;
                                    int titleHeight = 50; int messageHeight = 100; int chatHeight = 100;
                                    int maxWidth = [UIScreen mainScreen].bounds.size.width;
                                    int maxHeight  = [UIScreen mainScreen].bounds.size.height;
                                    float viewWidth = maxWidth * 0.6;
                                    float viewHeight = edge + titleHeight + gap + messageHeight + gap + chatHeight + gap + 50;
                                    float x = edge;
                                    float y = edge;

                                    UIView *messageAnswerView = [[UIView alloc] initWithFrame:CGRectMake((maxWidth - viewWidth)/2,
                                                                                                         (maxHeight - viewHeight)/2,
                                                                                                         viewWidth,
                                                                                                         viewHeight)];
                                  //  messageAnswerView.tag = ANSWERREPLY_VIEW;
                                    messageAnswerView.backgroundColor = [UIColor colorNamed:@"ColorAnswerView"];
                                    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                                               y,
                                                                                               viewWidth - edge - edge,
                                                                                               titleHeight)];
                                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[self.boardDict objectForKey:@"quickMessage"]];
                                    [attr addAttribute:NSFontAttributeName
                                                 value:[UIFont systemFontOfSize:30.0]
                                                 range:NSMakeRange(0, [attr length])];
                                    [title setAttributedText:attr];

                                    title.adjustsFontSizeToFitWidth = YES;
                                    title.numberOfLines = 0;
                                    title.minimumScaleFactor = 0.5;
                                    title.backgroundColor = [UIColor colorNamed:@"ColorAnswerTitle"];
                                    title.textAlignment = NSTextAlignmentCenter;
                                    y += titleHeight + gap;
                                    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(x,
                                                                                               y,
                                                                                               viewWidth - edge - edge,
                                                                                               messageHeight)];
                                    attr = [[NSMutableAttributedString alloc] initWithString:[self.boardDict objectForKey:@"chat"]];
                                    [attr addAttribute:NSFontAttributeName
                                                 value:[UIFont systemFontOfSize:20.0]
                                                 range:NSMakeRange(0, [attr length])];
                                    [message setAttributedText:attr];
                                    message.backgroundColor = [UIColor colorNamed:@"ColorAnswerMessage"];
                                    message.adjustsFontSizeToFitWidth = YES;
                                    message.numberOfLines = 0;
                                    message.minimumScaleFactor = 0.5;
                                    message.textAlignment = NSTextAlignmentCenter;
                                    y += messageHeight + gap;
        
                                    self->quickmessageChat = [[UITextView alloc] initWithFrame:CGRectMake(x,
                                                                                                          y,
                                                                                                          viewWidth - edge - edge,
                                                                                                          chatHeight)];
                                    [self->quickmessageChat setFont:[UIFont systemFontOfSize:20]];
                                    self->quickmessageChat.text = @"You may chat here";
                                    self->quickmessageChat.delegate = self;
                                    self->quickmessageChat.backgroundColor = [UIColor colorNamed:@"ColorAnswerChat"];
                                    self->quickmessageChatViewFrame = self->quickmessageChat.frame;
                                    y += chatHeight + gap + gap;

                                    DGButton *buttonNext = [[DGButton alloc] initWithFrame:CGRectMake(messageAnswerView.frame.size.width - 120 - edge - gap, y, 120, 35)];
                                    [buttonNext setTitle:@"Send Reply" forState: UIControlStateNormal];
                                    [buttonNext addTarget:self action:@selector(actionSendReplay) forControlEvents:UIControlEventTouchUpInside];

                                    DGButton *buttonCancel = [[DGButton alloc] initWithFrame:CGRectMake(x + gap, y, 120, 35)];
                                    [buttonCancel setTitle:@"Cancel" forState: UIControlStateNormal];
                                    [buttonCancel addTarget:self action:@selector(actionCancelReplay) forControlEvents:UIControlEventTouchUpInside];

                                    [messageAnswerView addSubview:buttonCancel];
                                    [messageAnswerView addSubview:buttonNext];
                                    [messageAnswerView addSubview:title];
                                    [messageAnswerView addSubview:message];
                                    [messageAnswerView addSubview:self->quickmessageChat];
                                    messageAnswerView.layer.borderWidth = 1.0;

                                    [self.view addSubview:messageAnswerView];
                                }];

    [alert addAction:yesButton];
    [alert addAction:answerButton];
    alert.view.tag = ALERT_VIEW_TAG;

    [self presentViewController:alert animated:YES completion:nil];
    return;

}

#pragma mark - textView
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    if (!([textView.text rangeOfString:@"You may chat with"].location == NSNotFound))
    {
        textView.text = @"";
    }
    if (!([textView.text rangeOfString:@"You may chat here"].location == NSNotFound))
    {
        textView.text = @"";
    }

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [textView endEditing:YES];
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if(isQuickmessage)
    {
        CGRect frame = quickmessageChatViewFrame;
        frame.origin.y = 50;
        quickmessageChat.frame = frame;
    }
    if(isFinishedMatch)
    {
        CGRect frame = finishedmatchChatViewFrame;
        frame.origin.y = 50;
        finishedMatchChat.frame = frame;
    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view endEditing:YES];
    if(isFinishedMatch)
        finishedMatchChat.frame = finishedmatchChatViewFrame;
    if(isQuickmessage)
        quickmessageChat.frame = quickmessageChatViewFrame;

}

#pragma mark - actions textView finished match
- (void)actionNextFinishedMatch:(UIButton*)button
{
    [finishedMatchChat endEditing:YES];

    NSString *href = (NSString *)[button.layer valueForKey:@"href"];
    NSString *nextButtonText = @"Next%20Game";
    NSString * matchLink = @"";

    NSMutableDictionary *finishedMatchDict = [self.boardDict objectForKey:@"finishedMatch"] ;
    
    if([[finishedMatchDict objectForKey:@"NextButton"] isEqualToString:@"Next"])
        nextButtonText = @"Next";
    
    NSArray *chatArray = [finishedMatchDict objectForKey:@"chat"];
    if([chatArray[0] containsString:@"chat"])
    {
        NSString *chatString = [tools cleanChatString:finishedMatchChat.text];

        if(chatString)
            chatString = [NSString stringWithFormat:@"&chat=%@",chatString];
        if([href isEqualToString:@""])
            matchLink = @"/bg/nextgame";
        else
            matchLink = [NSString stringWithFormat:@"%@?submit=%@&commit=1%@", href,nextButtonText, chatString];
    }
    else
    {
        if([href isEqualToString:@""])
            matchLink = @"/bg/nextgame";
        else
            matchLink = [NSString stringWithFormat:@"%@?submit=%@&commit=1", href, nextButtonText];
    }

    [self playMatch:matchLink];
}

- (void)actionToTopFinishedMatch:(UIButton*)button
{
    [finishedMatchChat endEditing:YES];

    NSString *href = (NSString *)[button.layer valueForKey:@"href"];
    NSString *chatString = [tools cleanChatString:finishedMatchChat.text];
    if(chatString)
        chatString = [NSString stringWithFormat:@"&chat=%@",chatString];

    NSString *matchLink = [NSString stringWithFormat:@"%@?submit=To%%20Top&commit=1&chat=%@", href, chatString];
    NSURL *urlMatch = [NSURL URLWithString:[NSString stringWithFormat:@"http://dailygammon.com%@",matchLink]];
    
    DGRequest *request = [[DGRequest alloc] initWithURL:urlMatch completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            TopPageCV *vc = [[UIStoryboard storyboardWithName:@"iPad" bundle:nil]  instantiateViewControllerWithIdentifier:@"TopPageCV"];

            [self.navigationController pushViewController:vc animated:NO];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;

}

#pragma mark - actions textView reply quickmessage

- (void) actionSendReplay
{

    [quickmessageChat endEditing:YES];

    NSMutableDictionary *actionDict = [self.boardDict objectForKey:@"messageDict"];
    NSMutableArray *attributesArray = [actionDict objectForKey:@"attributes"];
    NSMutableDictionary *dict = attributesArray[0];

    NSString *chatString = [tools cleanChatString:quickmessageChat.text];
    NSString *matchLink = @"";

    matchLink = [NSString stringWithFormat:@"%@?submit=Send%%20Reply&text=%@",
                 [dict objectForKey:@"action"],
                 chatString];
    [self playMatch:matchLink];
}
- (void) actionCancelReplay
{
    [quickmessageChat endEditing:YES];

    NSString *matchLink = [NSString stringWithFormat:@"/bg/nextgame?submit=Next"];
    [self playMatch:matchLink];
}

#pragma mark - Header

- (IBAction)moreAction:(id)sender
{
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}

@end
