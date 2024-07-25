//
//  TextModul.m
//  DailyGammon
//
//  Created by Peter Schneider on 03.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "TextModul.h"
#import "DGLabel.h"
#import "DGButton.h"
#import "Design.h"
#import "TextModulEdit.h"

#import "AppDelegate.h"
#import "Phrases+CoreDataProperties.h"
 
@interface TextModul ()

@property (weak, nonatomic) IBOutlet DGButton *doneButton;
@property (weak, nonatomic) IBOutlet DGButton *editButton;
@property (weak, nonatomic) IBOutlet DGButton *addButton;
@property (weak, nonatomic) IBOutlet DGButton *helpButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TextModul

@synthesize design;
@synthesize textModulArray;

@synthesize textView;
@synthesize isSetup;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(updateTableView)
               name:@"textModulHasChanged"
             object:nil];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 14.0f;
    self.tableView.layer.borderColor = [design getTintColorSchema].CGColor;
    self.tableView.sectionHeaderTopPadding = 0;
    [self layoutObjects];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
    [self readArray];
    [self.tableView reloadData];
}
-(void) readArray
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phrases" inManagedObjectContext:context];
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"quantityUsed" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    textModulArray = [[context executeFetchRequest:request error:&error] mutableCopy];

}

- (void)defaultPhrases
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

    NSMutableArray *templateArray = [[NSMutableArray alloc] initWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1], @"number",
                              [NSNumber numberWithInt:0], @"quantityUsed",
                              @"Hi & GL", @"shortText",
                              @"Hi & Good luck", @"longText",
                              nil],
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:2], @"number",
                              [NSNumber numberWithInt:0], @"quantityUsed",
                              @"congrats", @"shortText",
                              @"Congratulations to you. Good luck in the tournament.", @"longText",
                              nil],
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:3], @"number",
                              [NSNumber numberWithInt:0], @"quantityUsed",
                              @"TY GM", @"shortText",
                              @"Thank you. That was a good and exciting match.", @"longText",
                              nil],
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:4], @"number",
                              [NSNumber numberWithInt:0], @"quantityUsed",
                              @"42", @"shortText",
                              @"The Answer to the Great Question... Of Life, the Universe and Everything... Is... Forty-two,' said Deep Thought, with infinite majesty and calm.", @"longText",
                              nil],
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:5], @"number",
                              [NSNumber numberWithInt:0], @"quantityUsed",
                              @"So long", @"shortText",
                              @"So long, and thanks for all the fish.", @"longText",
                              nil],
                            nil];

    for(NSMutableDictionary *dict in templateArray)
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phrases" inManagedObjectContext:context];
        NSError *error;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
        [request setFetchLimit:1];
 
        NSMutableArray *arrayDB = [[context executeFetchRequest:request error:&error] mutableCopy];
        int newNumber = 0;
        if(arrayDB.count > 0)
        {
            Phrases *phrase = arrayDB[0];
            newNumber       = phrase.number + 1;
        }
        else
        {
            newNumber = 1;
        }
        Phrases *phraseNew = (Phrases *)[NSEntityDescription insertNewObjectForEntityForName:@"Phrases" inManagedObjectContext:context];
        phraseNew.number       = newNumber;
        phraseNew.quantityUsed = 0;
        phraseNew.shortText    = [dict objectForKey:@"shortText"];
        phraseNew.longText     = [dict objectForKey:@"longText"];

        if (![context save:&error])
        {
            // Something's gone seriously wrong
            XLog(@"Error saving Phrases %@", [error localizedDescription]);
        }
    }

}
-(void)updateTableView
{
    [self readArray];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.textModulArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Phrases *dict = textModulArray[indexPath.row];

     UIFont *font = [UIFont systemFontOfSize:15.0];
     CGFloat cellWidth = tableView.frame.size.width - 100;
     CGFloat maxHeight = 200;
     CGSize textSize = [dict.longText boundingRectWithSize:CGSizeMake(cellWidth, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName: font}
                                                   context:nil].size;

    int labelHeight = 25;

    CGFloat cellHeight = textSize.height + labelHeight + 5;
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat borderWidth = 1.0 / [UIScreen mainScreen].scale;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    view.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];

    DGLabel *label = [[DGLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
    [label setText:@"Used"];
    label.layer.borderWidth = borderWidth;
    [view addSubview:label];
    
    label = [[DGLabel alloc] initWithFrame:CGRectMake(50, 0, tableView.frame.size.width-50, 25)];
    [label setText:@"Short Text"];
    label.layer.borderWidth = borderWidth;

    [view addSubview:label];

    label = [[DGLabel alloc] initWithFrame:CGRectMake(0, 25, tableView.frame.size.width, 25)];
    [label setText:@"Long Text"];
    label.textColor = [design getTintColorSchema] ;
    label.layer.borderWidth = borderWidth;
    [view addSubview:label];

    return view;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [subview removeFromSuperview];
        }
        if ([subview isKindOfClass:[DGLabel class]])
        {
            [subview removeFromSuperview];
        }
    }
    cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];;
//    if (indexPath.row % 2)
//        cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];
//    else
//        cell.backgroundColor = [UIColor colorNamed:@"ColorButtonGradientCenter"];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    Phrases *dict = textModulArray[indexPath.row];

    int x = 0;
    int labelHeight = 25;
    
    UILabel *used = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,50,labelHeight)];
    used.textAlignment = NSTextAlignmentCenter;
    used.text = [NSString stringWithFormat:@"%d",dict.quantityUsed];
  //  used.layer.borderWidth = 1;
    [cell.contentView addSubview:used];

    x += 50;
    
    DGLabel *nameLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,tableView.frame.size.width-50 ,labelHeight)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = [NSString stringWithFormat:@"%@", dict.shortText];
  //  nameLabel.layer.borderWidth = 1;
    [cell.contentView addSubview:nameLabel];
    
    x = 0;
    DGLabel *longtext = [[DGLabel alloc] initWithFrame:CGRectMake(x, labelHeight ,tableView.frame.size.width - 50,cell.contentView.frame.size.height-labelHeight)];
    longtext.textAlignment = NSTextAlignmentLeft;
    longtext.text = [NSString stringWithFormat:@"%@", dict.longText];
    longtext.textColor = [design getTintColorSchema] ;
    longtext.numberOfLines = 0;
    longtext.adjustsFontSizeToFitWidth = YES;
    longtext.lineBreakMode = NSLineBreakByWordWrapping;

    [cell.contentView addSubview:longtext];
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Phrases *dict = textModulArray[indexPath.row];
    if(isSetup || (self.tableView.isEditing == true))
    {
        // edit
        TextModulEdit *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TextModulEdit"];
        
        controller.modalPresentationStyle = UIModalPresentationPopover;
        controller.phraseEdit = textModulArray[indexPath.row];
        [self presentViewController:controller animated:NO completion:nil];
        
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionRight;
        popController.delegate = self;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        popController.sourceView = cell;
        popController.sourceRect = cell.bounds;

    }
    else
    {
        NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phrases" inManagedObjectContext:context];
        NSError *error;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %d",dict.number];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setEntity:entity];
        NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
        Phrases *phrase = arrResult[0];
        phrase.quantityUsed         = dict.quantityUsed + 1;
        
        if (![context save:&error])
        {
            // Something's gone seriously wrong
            XLog(@"Error updating Phrases %@", [error localizedDescription]);
        }

        textView.text = [textView.text stringByAppendingString:dict.longText];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"textViewTextHasChanged" object:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)editAction:(id)sender 
{
    if(self.tableView.isEditing == true)
    {
        self.tableView.editing = false;
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else
    {
        self.tableView.editing = true;
        [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
     return YES;
 }
 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Phrases *dict = textModulArray[indexPath.row];
        NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phrases" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %d",dict.number];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *error;
        NSArray *items = [context executeFetchRequest:fetchRequest error:&error];

        for (NSManagedObject *managedObject in items)
        {
            [context deleteObject:managedObject];
        }
        if (![context save:&error])
        {
            // Something's gone seriously wrong
            XLog(@"Error deleting Phrases %@", [error localizedDescription]);
        }

        [self readArray];
        [self.tableView reloadData];
    }
}

- (IBAction)helpAction:(id)sender 
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Information"
                                 message:@"Wherever you can enter texts (Chats, QuickMessages), TextModules are available for selection. You can of course create, change and delete as many texts as you like. \n\nIf you want me to create a small selection of texts for you (there are only 5), just tap the \"Yes please\" button. \n\nHave fun with the texts. "
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes please"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self defaultPhrases];
                                    [self readArray];
                                    [self.tableView reloadData];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                                actionWithTitle:@"No, thanks"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                }];

    [alert addAction:yesButton];
    [alert addAction:noButton];

    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)addAction:(id)sender 
{
    TextModulEdit *controller = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"TextModulEdit"];
    
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:NO completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;

}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    float edge = 10.0;
    float gap  = 10.0;
    
#pragma mark doneButton autoLayout
    [self.doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.doneButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.doneButton.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.doneButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.doneButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark editButton autoLayout
    [self.editButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.editButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.editButton.rightAnchor  constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.editButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.editButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark addButton autoLayout
    [self.addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.addButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.addButton.rightAnchor  constraintEqualToAnchor:self.editButton.leftAnchor constant:-edge].active = YES;
    [self.addButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.addButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark helpButton autoLayout
    [self.helpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.helpButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.helpButton.rightAnchor  constraintEqualToAnchor:self.addButton.leftAnchor constant:-edge].active = YES;
    [self.helpButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.helpButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark tableView autoLayout
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.tableView.topAnchor    constraintEqualToAnchor:self.doneButton.bottomAnchor                constant:gap].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor                constant:-edge].active = YES;
    [self.tableView.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.tableView.rightAnchor  constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

}


@end
