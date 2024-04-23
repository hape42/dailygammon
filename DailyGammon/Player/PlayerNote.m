//
//  PlayerNote.m
//  DailyGammon
//
//  Created by Peter Schneider on 25.03.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "PlayerNote.h"
#import "DGButton.h"
#import "Design.h"
#import "Tools.h"
#import "DGRequest.h"
#import "TextModul.h"
#import "Player+CoreDataProperties.h"
#import "AppDelegate.h"

@interface PlayerNote ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (strong, readwrite, retain, atomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet DGButton *saveButton;
@property (weak, nonatomic) IBOutlet DGButton *cancelButton;

@end

@implementation PlayerNote

@synthesize design, tools;
@synthesize playerID, playerName;
@synthesize editNote;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    tools = [[Tools alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];

    [self layoutObjects];

    editNote = NO;
    
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID like %@",playerID];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];

    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    if(items.count > 0)
    {
        Player *player = items[0];
        self.textView.text = player.note;
        editNote = YES;
    }
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
    float buttonHight = 35;

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:edge].active = YES;
    [self.header.heightAnchor constraintEqualToConstant:60 ].active = YES;
    [self.header.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.header.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    
#pragma mark textView autoLayout
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.textView.bottomAnchor constraintEqualToAnchor:self.saveButton.topAnchor constant:-gap].active = YES;
    [self.textView.heightAnchor constraintEqualToConstant:120].active = YES;
    [self.textView.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.textView.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

#pragma mark hide keyboard Button

    UIButton *keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, buttonHight)];
    keyboardButton = [design designKeyBoardDownButton:keyboardButton];
    [keyboardButton addTarget:self action:@selector(textViewShouldEndEditing:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:keyboardButton];

    [keyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [keyboardButton.topAnchor constraintEqualToAnchor:self.saveButton.topAnchor constant:0].active = YES;
    [keyboardButton.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [keyboardButton.widthAnchor constraintEqualToConstant:40].active = YES;
    [keyboardButton.rightAnchor constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;


#pragma mark saveButton autoLayout
    [self.saveButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.saveButton.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor constant:-edge].active = YES;
    [self.saveButton.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.saveButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.saveButton.widthAnchor  constraintEqualToConstant:80].active = YES;

#pragma mark cancelButton autoLayout
    [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.saveButton.topAnchor constant:0].active = YES;
    [self.cancelButton.leftAnchor constraintEqualToAnchor:self.saveButton.rightAnchor constant:gap].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.cancelButton.widthAnchor  constraintEqualToConstant:80].active = YES;

}

-(IBAction)actionSave:(id)sender
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    if(editNote)
    {
        // update
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
        NSError *error;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID like %@",playerID];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setEntity:entity];
        NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
        Player *player = arrResult[0];
        player.note = self.textView.text;

        if (![context save:&error])
        {
            // Something's gone seriously wrong
            NSLog(@"Error saving Notes");
        }
    }
    else
    {
        // new

        NSError *error;

        Player *player = (Player *)[NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
        player.userID  = playerID;
        player.note    = self.textView.text;

        if (![context save:&error])
        {
            // Something's gone seriously wrong
            NSLog(@"Error saving Note");
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)actionCancelSend:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

@end
