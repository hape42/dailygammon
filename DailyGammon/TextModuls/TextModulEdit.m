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
#import "AppDelegate.h"

@interface TextModulEdit ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *usedLabel;
@property (weak, nonatomic) IBOutlet UITextView *used;
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
@synthesize phraseEdit;

- (void)viewDidLoad
{
    [super viewDidLoad];

    design = [[Design alloc] init];

    [self layoutObjects];
    
    if(phraseEdit != nil)
    {
        self.header.text = @"Edit Text Modul";
        self.shortText.text = phraseEdit.shortText;
        self.longText.text = phraseEdit.longText;
        self.used.text = [NSString stringWithFormat:@"%d",phraseEdit.quantityUsed] ;
    }
    else
    {
        self.header.text = @"New Text Modul";
        self.used.text = [NSString stringWithFormat:@"%d",0] ;
    }

}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
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

#pragma mark used
    [self.usedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.usedLabel.topAnchor    constraintEqualToAnchor:self.header.bottomAnchor constant:gap].active = YES;
    [self.usedLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor          constant:edge].active = YES;
    [self.usedLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.usedLabel.widthAnchor  constraintEqualToConstant:buttonWidth].active = YES;

    [self.used setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.used.topAnchor    constraintEqualToAnchor:self.header.bottomAnchor   constant:gap].active = YES;
    [self.used.leftAnchor   constraintEqualToAnchor:self.usedLabel.rightAnchor constant:gap].active = YES;
    [self.used.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.used.widthAnchor  constraintEqualToConstant:50].active = YES;


#pragma mark shortText
    [self.shortTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.shortTextLabel.topAnchor    constraintEqualToAnchor:self.used.bottomAnchor constant:gap].active = YES;
    [self.shortTextLabel.leftAnchor   constraintEqualToAnchor:safe.leftAnchor        constant:edge].active = YES;
    [self.shortTextLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.shortTextLabel.widthAnchor  constraintEqualToConstant:buttonWidth].active = YES;

    [self.shortText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.shortText.topAnchor    constraintEqualToAnchor:self.used.bottomAnchor          constant:gap].active = YES;
    [self.shortText.rightAnchor  constraintEqualToAnchor:safe.rightAnchor                constant:-edge].active = YES;
    [self.shortText.leftAnchor   constraintEqualToAnchor:self.shortTextLabel.rightAnchor constant:gap].active = YES;
    [self.shortText.heightAnchor constraintEqualToConstant:buttonHight].active = YES;

#pragma mark longText
    [self.longTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.longTextLabel.centerYAnchor constraintEqualToAnchor:self.longText.centerYAnchor constant:0].active = YES;
    [self.longTextLabel.heightAnchor constraintEqualToConstant:buttonHight].active = YES;
    [self.longTextLabel.widthAnchor constraintEqualToConstant:buttonWidth].active = YES;
    [self.longTextLabel.leftAnchor constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;

    [self.longText setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.longText.topAnchor    constraintEqualToAnchor:self.shortText.bottomAnchor    constant:gap].active = YES;
    [self.longText.rightAnchor  constraintEqualToAnchor:safe.rightAnchor               constant:-edge].active = YES;
    [self.longText.leftAnchor   constraintEqualToAnchor:self.longTextLabel.rightAnchor constant:gap].active = YES;
    [self.longText.heightAnchor constraintEqualToConstant:150].active = YES;
   // [self.longText.bottomAnchor constraintEqualToAnchor:self.keyboardButton.topAnchor constant:-gap].active = YES;

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
- (IBAction)saveAction:(id)sender 
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    if(phraseEdit != nil)
    {
        // update
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phrases" inManagedObjectContext:context];
        NSError *error;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %d",phraseEdit.number];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setEntity:entity];
        NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
        Phrases *phrase = arrResult[0];
        phrase.quantityUsed = [self.used.text intValue];
        phrase.shortText    = self.shortText.text;
        phrase.longText     = self.longText.text;

        if (![context save:&error])
        {
            // Something's gone seriously wrong
            NSLog(@"Error saving Phrases");
        }

    }
    else
    {
        // new
        self.header.text = @"New Text Modul";
        self.used.text = [NSString stringWithFormat:@"%d",0] ;
        

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phrases" inManagedObjectContext:context];
        NSError *error;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
        [request setFetchLimit:1];

        NSMutableArray *arrayDB = [[context executeFetchRequest:request error:&error] mutableCopy];
        Phrases *phrase = arrayDB[0];

        Phrases *phraseNew = (Phrases *)[NSEntityDescription insertNewObjectForEntityForName:@"Phrases" inManagedObjectContext:context];
        phraseNew.number       = phrase.number + 1;
        phraseNew.quantityUsed = [self.used.text intValue];
        phraseNew.shortText    = self.shortText.text;
        phraseNew.longText     = self.longText.text;

        if (![context save:&error])
        {
            // Something's gone seriously wrong
            NSLog(@"Error saving Phrases");
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"textModulHasChanged" object:self ];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
