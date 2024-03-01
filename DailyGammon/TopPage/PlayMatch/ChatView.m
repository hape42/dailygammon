//
//  MenueView.m
//  DailyGammon
//
//  Created by Peter Schneider on 29.12.23.
//  Copyright © 2023 Peter Schneider. All rights reserved.
//

#import "ChatView.h"
#import "Design.h"
#import "DGButton.h"
#import "Tools.h"

#import "AppDelegate.h"
#import "Constants.h"


@implementation ChatView

@synthesize design, tools;
@synthesize boardDict, actionDict, boardView;

@synthesize transparentButton, quoteSwitch, playerChat;
@synthesize navigationController, presentingVC;

- (id)init
{
    design      = [[Design alloc] init];

    if (self = [super initWithFrame:CGRectZero])
    {
        self.tag = 123;
        self.opaque = FALSE;
        self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        self.layer.borderWidth = 2;
        NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
        self.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
        self.layer.cornerRadius = 14.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)showChatInView:(UIView *)presentingView
{
    tools = [[Tools alloc] init];

    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTouched:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:oneFingerTap];

    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];

    float edge = 10.0;
    float gap = 10;
    float buttonWidth = 80.0;
    float buttonHight = 35;
        
    float headerSize = 30;
    float opponentChatHeight = 70;
    float playerChatHeight = 100;

    [presentingView addSubview:self];
    
    UILayoutGuide *safe = presentingView.safeAreaLayoutGuide;

    float chatViewHeight = edge + headerSize  + gap + playerChatHeight + gap + buttonHight + edge;
    if([[boardDict objectForKey:@"chat"] length] != 0)
        chatViewHeight      = edge + headerSize  + gap + opponentChatHeight + gap + headerSize + gap + playerChatHeight + gap + buttonHight + edge;

    while (chatViewHeight > (safe.layoutFrame.size.height - edge - edge))
    {
        opponentChatHeight *= .9;
        playerChatHeight   *= .9;
        if([[boardDict objectForKey:@"chat"] length] != 0)
            chatViewHeight      = edge + headerSize  + gap + opponentChatHeight + gap + headerSize + gap + playerChatHeight + gap + buttonHight + edge;
        else
            chatViewHeight      = edge + headerSize  + gap  + playerChatHeight + gap + buttonHight + edge;
    }

#pragma mark chatView
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.heightAnchor constraintEqualToConstant:chatViewHeight].active = YES;
    [self.leftAnchor   constraintEqualToAnchor:boardView.leftAnchor constant:0].active = YES;
    [self.widthAnchor  constraintEqualToConstant:boardView.frame.size.width].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:presentingView.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;

#pragma mark header
    DGLabel *header = [[DGLabel alloc] init];
    header.text = @"Chat";
    [header setFont:[UIFont boldSystemFontOfSize: 25.0]];
    header.numberOfLines = 0;
    header.minimumScaleFactor = 0.1;
    [self addSubview:header];

    [header setTranslatesAutoresizingMaskIntoConstraints:NO];

    [header.topAnchor constraintEqualToAnchor:self.topAnchor constant:edge].active = YES;
    [header.heightAnchor constraintEqualToConstant:headerSize].active = YES;
    [header.widthAnchor constraintEqualToConstant:100 ].active = YES;
    [header.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:edge].active = YES;

#pragma mark transparentButton
    transparentButton = [[UIButton alloc] init];
    transparentButton.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [transparentButton setImage:[[UIImage imageNamed:@"Brille"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [transparentButton addTarget:self action:@selector(chatTransparent) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:transparentButton];

    [transparentButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [transparentButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:edge].active = YES;
    [transparentButton.heightAnchor constraintEqualToConstant:headerSize].active = YES;
    [transparentButton.widthAnchor constraintEqualToConstant:headerSize].active = YES;
    [transparentButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-edge].active = YES;

#pragma mark historyButton
    UIButton *historyButton = [[UIButton alloc] init];
    [historyButton setImage:[[UIImage imageNamed:@"History"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [historyButton addTarget:self action:@selector(notYetImplemented:) forControlEvents:UIControlEventTouchUpInside];
    historyButton.tag = 1;
    [self addSubview:historyButton];

    [historyButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [historyButton.topAnchor constraintEqualToAnchor:transparentButton.topAnchor constant:0].active = YES;
    [historyButton.heightAnchor constraintEqualToConstant:headerSize].active = YES;
    [historyButton.widthAnchor constraintEqualToConstant:headerSize].active = YES;
    [historyButton.rightAnchor constraintEqualToAnchor:transparentButton.leftAnchor constant:-gap].active = YES;

#pragma mark quotesButton
    UIButton *quotesButton = [[UIButton alloc] init];
    [quotesButton setImage:[[UIImage imageNamed:@"Quotes"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [quotesButton addTarget:self action:@selector(notYetImplemented:) forControlEvents:UIControlEventTouchUpInside];
    quotesButton.tag = 2;
    [self addSubview:quotesButton];

    [quotesButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [quotesButton.topAnchor constraintEqualToAnchor:historyButton.topAnchor constant:0].active = YES;
    [quotesButton.rightAnchor constraintEqualToAnchor:historyButton.leftAnchor constant:-gap].active = YES;
    [quotesButton.heightAnchor constraintEqualToConstant:headerSize].active = YES;
    [quotesButton.widthAnchor constraintEqualToConstant:headerSize].active = YES;

#pragma mark nextButton

    DGButton *nextButton = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [nextButton setTitle:@"Next" forState: UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];

    [nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [nextButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-edge].active = YES;
    [nextButton.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:edge].active = YES;
    [nextButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [nextButton.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;

#pragma mark topButton

    DGButton *topButton = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHight)];
    [topButton setTitle:@"To Top" forState: UIControlStateNormal];
    [topButton addTarget:self action:@selector(topAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:topButton];

    [topButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [topButton.topAnchor constraintEqualToAnchor:nextButton.topAnchor constant:0].active = YES;
    [topButton.leftAnchor constraintEqualToAnchor:nextButton.rightAnchor constant:gap].active = YES;
    [topButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [topButton.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;
    
#pragma mark hide keyboard Button

    DGButton *keyboardButton = [[DGButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth * 2, buttonHight)];
    [keyboardButton setTitle:@"hide keyboard" forState: UIControlStateNormal];
    [keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:keyboardButton];

    [keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [keyboardButton.topAnchor constraintEqualToAnchor:topButton.topAnchor constant:0].active = YES;
    [keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [keyboardButton.widthAnchor constraintEqualToConstant:buttonWidth *2 ].active = YES;
    [keyboardButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-edge].active = YES;

#pragma mark - OpponentChat & switch & label

    NSMutableArray *attributesArray = [actionDict objectForKey:@"attributes"];
    
    BOOL isCheckbox = FALSE;
    for(NSMutableDictionary *dict in attributesArray)
    {
        if([[dict objectForKey:@"type"] isEqualToString:@"checkbox"])
        {
            isCheckbox = TRUE;;
        }
    }
#pragma mark OpponentChat
    UITextView *opponentChat = [[UITextView alloc] init];
    opponentChat.editable = NO;
    [opponentChat setFont:[UIFont systemFontOfSize:15]];
    opponentChat.backgroundColor = [UIColor clearColor];
    opponentChat.textColor = [schemaDict objectForKey:@"TintColor"];
    opponentChat.text = [boardDict objectForKey:@"chat"];
    opponentChat.layer.borderWidth = 1;
    opponentChat.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    opponentChat.layer.cornerRadius = 14.0f;
    opponentChat.layer.masksToBounds = YES;

    [self addSubview:opponentChat];
    if(([opponentChat.text length] != 0) && (isCheckbox == TRUE))
    {
        [opponentChat setTranslatesAutoresizingMaskIntoConstraints:NO];

        [opponentChat.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:gap].active = YES;
        [opponentChat.heightAnchor constraintEqualToConstant:opponentChatHeight].active = YES;
        [opponentChat.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:edge].active = YES;
        [opponentChat.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-edge].active = YES;

#pragma mark quoteSwitch
        quoteSwitch = [[UISwitch alloc] init];
        quoteSwitch = [design makeNiceSwitch:quoteSwitch];
        [quoteSwitch setOn:YES animated:YES];

        [self addSubview:quoteSwitch];

        [quoteSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];

        [quoteSwitch.topAnchor constraintEqualToAnchor:opponentChat.bottomAnchor constant:gap].active = YES;
        [quoteSwitch.heightAnchor constraintEqualToConstant:headerSize].active = YES;
        [quoteSwitch.leftAnchor constraintEqualToAnchor:opponentChat.leftAnchor constant:0].active = YES;

#pragma mark quoteLabel
        UILabel *quoteLabel = [[UILabel alloc] init];
        quoteLabel.text = @"Quote previous message";
        quoteLabel.textColor   = [schemaDict objectForKey:@"TintColor"];
        [self addSubview:quoteLabel];

        [quoteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [quoteLabel.topAnchor constraintEqualToAnchor:quoteSwitch.topAnchor constant:0].active = YES;
        [quoteLabel.heightAnchor constraintEqualToConstant:headerSize].active = YES;
        [quoteLabel.leftAnchor constraintEqualToAnchor:quoteSwitch.rightAnchor constant:gap].active = YES;

    }

#pragma mark - PlayerChat
    playerChat = [[UITextView alloc] init];
    [playerChat setFont:[UIFont systemFontOfSize:15]];
    playerChat.layer.borderWidth = 1;
    playerChat.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    playerChat.layer.cornerRadius = 14.0f;
    playerChat.layer.masksToBounds = YES;
    [playerChat setDelegate:self];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    playerChat.text = app.chatBuffer;
    [self addSubview:playerChat];
    
    [playerChat setTranslatesAutoresizingMaskIntoConstraints:NO];

    if(quoteSwitch)
        [playerChat.topAnchor constraintEqualToAnchor:quoteSwitch.bottomAnchor constant:gap].active = YES;
    else
        [playerChat.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:gap].active = YES;
    [playerChat.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:edge].active = YES;
    [playerChat.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-edge].active = YES;
    [playerChat.bottomAnchor constraintEqualToAnchor:nextButton.topAnchor constant:-gap].active = YES;

    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];

//    [UIView animateWithDuration:1.0  animations:^{
//            [self layoutIfNeeded];
//        }];

    return;
}

- (void)dismiss
{
//    [tools removeAllSubviewsRecursively:self];
    [self removeFromSuperview];

    return;
}

- (void)screenTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self];
    if( !CGRectContainsPoint(playerChat.frame, tapLocation) )
    {
        [playerChat endEditing:YES];
        // keyboard should dismiss
    }
}

#pragma mark - chatVieButtons actions

- (IBAction)chatTransparent
{
    if(self.backgroundColor == [UIColor clearColor])
    {
        self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        playerChat.backgroundColor = [UIColor whiteColor];

        [transparentButton setImage:[[UIImage imageNamed:@"Brille"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
        playerChat.backgroundColor = [UIColor clearColor];

        [transparentButton setImage:[[UIImage imageNamed:@"Brille_voll"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
}

- (IBAction)nextAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.chatBuffer = @"";

    [self dismiss];
    NSDictionary *userInfo = @{ @"playerChat" : playerChat.text,
                                @"quoteSwitch": @([quoteSwitch isOn])};
    [[NSNotificationCenter defaultCenter] postNotificationName:chatViewNextButtonNotification object:self userInfo:userInfo];
}

- (IBAction)topAction:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.chatBuffer = @"";

    [self dismiss];
    NSDictionary *userInfo = @{ @"playerChat" : playerChat.text,
                                @"quoteSwitch": @([quoteSwitch isOn])};
    [[NSNotificationCenter defaultCenter] postNotificationName:chatViewTopButtonNotification object:self userInfo:userInfo];
}

-(void)notYetImplemented:(id)sender
{
    NSString *title = @"not yet implemented";
    NSString *message = @"---";
    UIButton *button = (UIButton *)sender;

    switch(button.tag)
    {
        case 1:
            message = @"hier kann ich eine Chat History mit diesem User einsehen. Das wird auch von dem hauptmenüpunkt Player aus möglich sein \n\n derr jeweilige Text wird mit einem zeitstempel und einer info der Quelle ( match (mit link) oder shortmessage versehen.\n\nSuchen kopieren und löschen werden möglich sein";
            break;
        case 2:
            message = @"hier wird mal aus textbausteinen wie zum Beispiel \"Hi from germany. good luck\" oder \"Good match, congratulation\" auswählen können.\n\n Textbausteine anlegen, ändern löschen und verschieben in der Liste wird auch möglich sein";
            break;
        default:
            message = @"unknown Button";
            break;
            
    }
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
   [navigationController presentViewController:alert animated:YES completion:nil];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [self viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         // Code to be executed during the animation
//        
//     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         // Code to be executed after the animation is completed
//     }];
//    XLog(@"Neue Breite: %.2f, Neue Höhe: %.2f", size.width, size.height);
//}

#pragma mark - textView delegates
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification object:self];

    [playerChat endEditing:YES];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.chatBuffer = playerChat.text;
}

@end
