//
//  QuickMessage.m
//  DailyGammon
//
//  Created by Peter Schneider on 25.03.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "QuickMessage.h"
#import "DGButton.h"
#import "Design.h"
#import "TextTools.h"
#import "DGRequest.h"
#import "TextModul.h"

@interface QuickMessage ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (strong, readwrite, retain, atomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet DGButton *sendButton;
@property (weak, nonatomic) IBOutlet DGButton *cancelButton;

@end

@implementation QuickMessage

@synthesize design, textTools;
@synthesize playerNummer, playerName;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    design    = [[Design alloc] init];
    textTools = [[TextTools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [self layoutObjects];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
        
    [self.textView becomeFirstResponder];

}

#pragma mark - layoutObjects
-(void)layoutObjects
{
    
    self.header.text = [NSString stringWithFormat:@"Quick message to  %@", playerName];
    self.header.adjustsFontSizeToFitWidth = YES;
    self.header.numberOfLines = 0;
    self.header.minimumScaleFactor = 0.5;
    self.header.textColor = [design schemaColor];

    [self.textView setFont:[UIFont systemFontOfSize:15]];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [[design schemaColor] CGColor];
    self.textView.layer.cornerRadius = 14.0f;
    self.textView.layer.masksToBounds = YES;
    [self.textView setDelegate:self];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
    float labelWidth = 150;
    float labelHeight = 35;
    float buttonWidth = 80.0;
    float buttonHight = 35;

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.header.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
    [self.header.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.header.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    
#pragma mark textView autoLayout
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.textView.bottomAnchor constraintEqualToAnchor:self.sendButton.topAnchor constant:-gap].active = YES;
    [self.textView.heightAnchor constraintEqualToConstant:120].active = YES;
    [self.textView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.textView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark hide keyboard Button

    UIButton *keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, buttonHight)];
    keyboardButton = [design designKeyBoardDownButton:keyboardButton];
    [keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:keyboardButton];

    [keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [keyboardButton.topAnchor constraintEqualToAnchor:self.sendButton.topAnchor constant:0].active = YES;
    [keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [keyboardButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [keyboardButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark historyButton
    UIButton *historyButton = [[UIButton alloc] init];
    historyButton = [design designChatHistoryButton:historyButton];
    [historyButton addTarget:self action:@selector(notYetImplemented) forControlEvents:UIControlEventTouchUpInside];
    historyButton.tag = 1;
    [self.view addSubview:historyButton];

    [historyButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [historyButton.topAnchor constraintEqualToAnchor:self.sendButton.topAnchor constant:0].active = YES;
    [historyButton.heightAnchor constraintEqualToConstant:30].active = YES;
    [historyButton.widthAnchor constraintEqualToConstant:30].active = YES;
    [historyButton.rightAnchor constraintEqualToAnchor:keyboardButton.leftAnchor constant:-gap].active = YES;

#pragma mark phrasesButton
    UIButton *phrasesButton = [[UIButton alloc] init];
    phrasesButton = [design designChatPhrasesButton:phrasesButton];
    [phrasesButton addTarget:self action:@selector(textModul:) forControlEvents:UIControlEventTouchUpInside];
    phrasesButton.tag = 2;
    [self.view addSubview:phrasesButton];

    [phrasesButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [phrasesButton.topAnchor constraintEqualToAnchor:historyButton.topAnchor constant:0].active = YES;
    [phrasesButton.rightAnchor constraintEqualToAnchor:historyButton.leftAnchor constant:-gap].active = YES;
    [phrasesButton.heightAnchor constraintEqualToConstant:30].active = YES;
    [phrasesButton.widthAnchor constraintEqualToConstant:30].active = YES;
    


#pragma mark sendButton autoLayout
    [self.sendButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.sendButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    [self.sendButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.sendButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.sendButton.widthAnchor  constraintEqualToConstant:80].active = YES;

#pragma mark cancelButton autoLayout
    [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.sendButton.topAnchor constant:0].active = YES;
    [self.cancelButton.leftAnchor constraintEqualToAnchor:self.sendButton.rightAnchor constant:gap].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.cancelButton.widthAnchor  constraintEqualToConstant:80].active = YES;

}

-(IBAction)actionSend:(id)sender
{
    NSString *escapedString = [textTools cleanChatString:self.textView.text];

    DGRequest *request = [[DGRequest alloc] initWithString:[NSString stringWithFormat:@"http://dailygammon.com/bg/sendmsg/%@?text=%@",playerNummer,escapedString] completionHandler:^(BOOL success, NSError *error, NSString *result)
                          {
        if (success)
        {
            [self.textView resignFirstResponder];

            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Quick message"
                                         message:[NSString stringWithFormat:@"Your message has been sent to %@",self->playerName]
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                [self dismissViewControllerAnimated:YES completion:nil];

                                       }];
            
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            XLog(@"Error: %@", error.localizedDescription);
        }
    }];
    request = nil;

}

-(IBAction)actionCancelSend:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
#pragma mark - textView delegates
-(BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{

    [self.textView endEditing:YES];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
}
-(void)textModul:(id)sender
{
 
    TextModul *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TextModul"];
    
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.textView = self.textView;
    controller.isSetup = NO;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

@end
