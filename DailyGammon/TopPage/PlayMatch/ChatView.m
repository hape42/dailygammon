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
    float gap = 20;
    float buttonWidth = 100.0;
    float buttonHight = 35;
        
    float headerButtonSize = 30;
    float x =  edge;
    float y = edge;

    
    // opponentChat fals was da ist
    // reply switch fals opponent da ist
    // reply text "Quote previous message"
    // textView
    // next button
    // to Top button
    
    [presentingView addSubview:self];
    
    // Add the view at the front of the app's windows
    UILayoutGuide *safe = presentingView.safeAreaLayoutGuide;

    float chatViewHeight = presentingView.frame.size.height/2;
        
#pragma mark chatView
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];


    NSLayoutConstraint *chatViewYConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:edge * 2];
   
    NSLayoutConstraint *chatViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:boardView.frame.origin.x];
    
    NSLayoutConstraint *chatViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:boardView.frame.size.width];
    
    NSLayoutConstraint *chatViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:chatViewHeight];

    [presentingView addConstraints:@[chatViewYConstraint, chatViewLeftConstraint,chatViewWidthConstraint,chatViewHeightConstraint]];

#pragma mark header
    DGLabel *header = [[DGLabel alloc] init];
    header.text = @"Chat";
    [header setFont:[UIFont boldSystemFontOfSize: 25.0]];
    header.numberOfLines = 0;
    header.minimumScaleFactor = 0.1;
    [self addSubview:header];

    [header setTranslatesAutoresizingMaskIntoConstraints:NO];


    NSLayoutConstraint *headerYConstraint = [NSLayoutConstraint constraintWithItem:header
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:10];
   
    NSLayoutConstraint *headerLeftConstraint = [NSLayoutConstraint constraintWithItem:header
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:10];
    
    // Fixed width
    NSLayoutConstraint *headerWidthConstraint = [NSLayoutConstraint constraintWithItem:header
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:100];
    // Fixed Height
    NSLayoutConstraint *headerHeightConstraint = [NSLayoutConstraint constraintWithItem:header
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:headerButtonSize];

    [self addConstraints:@[headerYConstraint, headerLeftConstraint,headerWidthConstraint,headerHeightConstraint]];

#pragma mark transparentButton
    transparentButton = [[UIButton alloc] init];
    [transparentButton setImage:[[UIImage imageNamed:@"Brille"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [transparentButton addTarget:self action:@selector(chatTransparent) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:transparentButton];

    [transparentButton setTranslatesAutoresizingMaskIntoConstraints:NO];


    NSLayoutConstraint *transparentButtonYConstraint = [NSLayoutConstraint constraintWithItem:transparentButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:10];
   
    NSLayoutConstraint *transparentButtonRightConstraint = [NSLayoutConstraint constraintWithItem:transparentButton
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute: NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:-10];
    
    // Fixed width
    NSLayoutConstraint *transparentButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:transparentButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:headerButtonSize];
    // Fixed Height
    NSLayoutConstraint *transparentButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:transparentButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:headerButtonSize];

    [self addConstraints:@[transparentButtonYConstraint, transparentButtonRightConstraint,transparentButtonWidthConstraint,transparentButtonHeightConstraint]];

#pragma mark historyButton
    UIButton *historyButton = [[UIButton alloc] init];
    [historyButton setImage:[[UIImage imageNamed:@"History"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [historyButton addTarget:self action:@selector(notYetImplemented:) forControlEvents:UIControlEventTouchUpInside];
    historyButton.tag = 1;
    [self addSubview:historyButton];

    [historyButton setTranslatesAutoresizingMaskIntoConstraints:NO];


    NSLayoutConstraint *historyButtonYConstraint = [NSLayoutConstraint constraintWithItem:historyButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:transparentButton
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];
   
    NSLayoutConstraint *historyButtonRightConstraint = [NSLayoutConstraint constraintWithItem:historyButton
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:transparentButton
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:-gap];
    
    // Fixed width
    NSLayoutConstraint *historyButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:historyButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:headerButtonSize];
    // Fixed Height
    NSLayoutConstraint *historyButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:historyButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:headerButtonSize];

    [self addConstraints:@[historyButtonYConstraint, historyButtonRightConstraint,historyButtonWidthConstraint,historyButtonHeightConstraint]];

#pragma mark quotesButton
    UIButton *quotesButton = [[UIButton alloc] init];
    [quotesButton setImage:[[UIImage imageNamed:@"Quotes"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [quotesButton addTarget:self action:@selector(notYetImplemented:) forControlEvents:UIControlEventTouchUpInside];
    quotesButton.tag = 2;
    [self addSubview:quotesButton];

    [quotesButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *quotesButtonYConstraint = [NSLayoutConstraint constraintWithItem:quotesButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:historyButton
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];
   
    NSLayoutConstraint *quotesButtonRightConstraint = [NSLayoutConstraint constraintWithItem:quotesButton
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:historyButton
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:-gap];
    
    // Fixed width
    NSLayoutConstraint *quotesButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:quotesButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:headerButtonSize];
    // Fixed Height
    NSLayoutConstraint *quotesButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:quotesButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:headerButtonSize];

    [self addConstraints:@[quotesButtonYConstraint, quotesButtonRightConstraint,quotesButtonWidthConstraint,quotesButtonHeightConstraint]];

#pragma mark nextButton

    DGButton *nextButton = [[DGButton alloc] init];
    [nextButton setTitle:@"Next" forState: UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];

    [nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *nextButtonYConstraint = [NSLayoutConstraint constraintWithItem:nextButton
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0f
                                                                              constant:-edge];
   
    NSLayoutConstraint *nextButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:nextButton
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:edge];
    
    // Fixed width
    NSLayoutConstraint *nextButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:nextButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:buttonWidth];
    // Fixed Height
    NSLayoutConstraint *nextButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:nextButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:buttonHight];

    [self addConstraints:@[nextButtonYConstraint, nextButtonLeftConstraint,nextButtonWidthConstraint,nextButtonHeightConstraint]];

#pragma mark topButton

    DGButton *topButton = [[DGButton alloc] init];
    [topButton setTitle:@"To Top" forState: UIControlStateNormal];
    [topButton addTarget:self action:@selector(top) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:topButton];

    [topButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *topButtonYConstraint = [NSLayoutConstraint constraintWithItem:topButton
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nextButton
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0f
                                                                              constant:0];
   
    NSLayoutConstraint *topButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:topButton
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nextButton
                                                                             attribute: NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:gap];
    
    // Fixed width
    NSLayoutConstraint *topButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:topButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:buttonWidth];
    // Fixed Height
    NSLayoutConstraint *topButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:topButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:buttonHight];

    [self addConstraints:@[topButtonYConstraint, topButtonLeftConstraint,topButtonWidthConstraint,topButtonHeightConstraint]];

#pragma mark - OpponentChat & switch & label

    float opponentChatHeight = chatViewHeight/7*1;
    float playerChatHeight = chatViewHeight/7*1;

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

    opponentChat.text = [boardDict objectForKey:@"chat"];
    opponentChat.text = @"Die Subdomain, für die Sie den CNAME hinterlegen, muss auch beim Zielserver bekannt sein, ansonsten erhalten Sie eine Fehlermeldung beim Aufruf der Subdomain. Nach der Änderung kann es ca. 3 - 4 Stunden dauern, bis der Eintrag aktiv ist. Loggen Sie sich im KAS (technische Verwaltung) ein und klicken Sie auf Tools -> DNS-Einstellungen.Bearbeiten Sie die Domain, für deren Subdomain Sie die Änderung vornehmen möchten, und klicken Sie anschließend auf neuen DNS-Eintrag erstellen.Schritt 2DNS-Werkzeuge - CNAME, Bild 2 Tragen Sie im Feld Name die gewünschte Subdomain ein (im Beispiel calendar). Bei Typ wählen Sie CNAME aus. Prio bleibt auf 0, in dem Feld Data tragen Sie die Zieldomain ein. Beachten Sie, dass am Ende des Hosts ein Punkt stehen muss.Anschließend klicken Sie auf die Schaltfäche speichern und der Eintrag wird vorgenommen.";
    opponentChat.layer.borderWidth = 1;
    opponentChat.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    opponentChat.layer.cornerRadius = 14.0f;
    opponentChat.layer.masksToBounds = YES;

    [self addSubview:opponentChat];
    if(([opponentChat.text length] != 0) && (isCheckbox == TRUE))
    {
        [opponentChat setTranslatesAutoresizingMaskIntoConstraints:NO];

        NSLayoutConstraint *opponentChatYConstraint = [NSLayoutConstraint constraintWithItem:opponentChat
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:header
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:edge];
       
        NSLayoutConstraint *opponentChatLeftConstraint = [NSLayoutConstraint constraintWithItem:opponentChat
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:edge];
        
        NSLayoutConstraint *opponentChatRightConstraint = [NSLayoutConstraint constraintWithItem:opponentChat
                                                                                     attribute:NSLayoutAttributeRight
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute: NSLayoutAttributeRight
                                                                                    multiplier:1.0
                                                                                      constant:-edge];
        
        NSLayoutConstraint *opponentChatHeightConstraint = [NSLayoutConstraint constraintWithItem:opponentChat
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1.0
                                                                                       constant:opponentChatHeight];

        [self addConstraints:@[opponentChatYConstraint, opponentChatLeftConstraint, opponentChatRightConstraint, opponentChatHeightConstraint]];

#pragma mark quoteSwitch
        quoteSwitch = [[UISwitch alloc] init];
        quoteSwitch = [design makeNiceSwitch:quoteSwitch];
        [quoteSwitch setOn:YES animated:YES];

        [self addSubview:quoteSwitch];

        [quoteSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];

        NSLayoutConstraint *quoteSwitchYConstraint = [NSLayoutConstraint constraintWithItem:quoteSwitch
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:opponentChat
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:gap];
       
        NSLayoutConstraint *quoteSwitchLeftConstraint = [NSLayoutConstraint constraintWithItem:quoteSwitch
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:opponentChat
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:0];
        
        // Fixed Height
        NSLayoutConstraint *quoteSwitchHeightConstraint = [NSLayoutConstraint constraintWithItem:quoteSwitch
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1.0
                                                                                       constant:headerButtonSize];

        [self addConstraints:@[quoteSwitchYConstraint, quoteSwitchLeftConstraint,quoteSwitchHeightConstraint]];

#pragma mark quoteLabel
        UILabel *quoteLabel = [[UILabel alloc] init];
        quoteLabel.text = @"Quote previous message";
        quoteLabel.textColor   = [schemaDict objectForKey:@"TintColor"];
        [self addSubview:quoteLabel];

        [quoteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

        NSLayoutConstraint *quoteLabelYConstraint = [NSLayoutConstraint constraintWithItem:quoteLabel
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:quoteSwitch
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1.0f
                                                                                  constant:0];
       
        NSLayoutConstraint *quoteLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:quoteLabel
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:quoteSwitch
                                                                                 attribute: NSLayoutAttributeRight
                                                                                multiplier:1.0
                                                                                  constant:gap];
        
        // Fixed Height
        NSLayoutConstraint *quoteLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:quoteLabel
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1.0
                                                                                       constant:headerButtonSize];

        [self addConstraints:@[quoteLabelYConstraint, quoteLabelLeftConstraint,quoteLabelHeightConstraint]];
    }

#pragma mark PlayerChat
    playerChat = [[UITextView alloc] init];
    [playerChat setFont:[UIFont systemFontOfSize:15]];
    playerChat.layer.borderWidth = 1;
    playerChat.layer.borderColor = [[schemaDict objectForKey:@"TintColor"] CGColor];
    playerChat.layer.cornerRadius = 14.0f;
    playerChat.layer.masksToBounds = YES;
    [playerChat setDelegate:(id)presentingVC];
    XLog(@"%@",presentingVC);

    [self addSubview:playerChat];
    
    [playerChat setTranslatesAutoresizingMaskIntoConstraints:NO];

    
    NSLayoutConstraint *playerChatYConstraint;
    if(quoteSwitch)
        playerChatYConstraint = [NSLayoutConstraint constraintWithItem:playerChat
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:quoteSwitch
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:gap];
       else
           playerChatYConstraint = [NSLayoutConstraint constraintWithItem:playerChat
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:quotesButton
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0f
                                                                                     constant:gap];

        NSLayoutConstraint *playerChatLeftConstraint = [NSLayoutConstraint constraintWithItem:playerChat
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:edge];
        
        NSLayoutConstraint *playerChatRightConstraint = [NSLayoutConstraint constraintWithItem:playerChat
                                                                                     attribute:NSLayoutAttributeRight
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute: NSLayoutAttributeRight
                                                                                    multiplier:1.0
                                                                                      constant:-edge];
        
        NSLayoutConstraint *playerChatBottomConstraint = [NSLayoutConstraint constraintWithItem:playerChat
                                                                                      attribute:NSLayoutAttributeBottom
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nextButton
                                                                                      attribute:NSLayoutAttributeTop
                                                                                     multiplier:1.0
                                                                                       constant:-gap];

        [self addConstraints:@[playerChatYConstraint, playerChatLeftConstraint, playerChatRightConstraint, playerChatBottomConstraint]];

    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:1.0  animations:^{
            [self layoutIfNeeded];
        }];

    return;
}

- (void)dismiss
{
    [tools removeAllSubviewsRecursively:self];
    [self removeFromSuperview];

    return;
}

- (void)screenTouched:(UIGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self];
    if( CGRectContainsPoint(self.frame, tapLocation) )
    {
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers)
        {
            [self removeGestureRecognizer:recognizer];
        }
     //   [self dismiss];
        
    }
    // if typing is done outside the chat, it will be ignored
}

- (IBAction)chatTransparent
{
    if(self.backgroundColor == [UIColor clearColor])
    {
        self.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];
        [transparentButton setImage:[[UIImage imageNamed:@"Brille"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
        [transparentButton setImage:[[UIImage imageNamed:@"Brille_voll"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
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
#pragma mark - textField
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    if([playerChat.text isEqualToString:@"you may chat here"])
    {
        playerChat.text = @"";
    }

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [playerChat endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect frame = self.frame;
        frame.origin.y -= 330;
        self.frame = frame;
    return;
}

-(void)keyboardDidHide:(NSNotification *)notification
{

    CGRect frame = self.frame;
        frame.origin.y += 330;
        self.frame = frame;

    return;
}
@end
