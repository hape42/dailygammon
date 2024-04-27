//
//  ChatHistory.m
//  DailyGammon
//
//  Created by Peter Schneider on 19.04.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "ChatHistory.h"
#import "DGLabel.h"
#import "DGButton.h"
#import "Design.h"
#import "AppDelegate.h"
#import "Chat+CoreDataProperties.h"
#import "Constants.h"

@interface ChatHistory ()

@property (weak, nonatomic) IBOutlet DGButton *doneButton;
@property (weak, nonatomic) IBOutlet DGButton *editButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet DGLabel *header;

@end

@implementation ChatHistory

@synthesize design;
@synthesize chatHistoryArray;

@synthesize playerID, playerName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    
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

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) readArray
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSMutableArray *predicates = [NSMutableArray array];
    
    request.entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"opponentID like %@", playerID];
    
    [predicates addObject:predicate];
    predicate = [NSPredicate predicateWithFormat:@"userID like %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"USERID"]];
    [predicates addObject:predicate];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    request.predicate =  compoundPredicate;
    [request setPredicate:compoundPredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    chatHistoryArray = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    return;
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
    return chatHistoryArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Chat *dict = chatHistoryArray[indexPath.row];
    
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CGFloat cellWidth = tableView.frame.size.width - 100;
    CGFloat maxHeight = 200;
    NSString *text = [self trimLeadingAndTrailingNewlinesFromString:dict.text];
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(cellWidth, maxHeight)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: font}
                                         context:nil].size;
    
    int labelHeight = 25;
    
    CGFloat cellHeight = textSize.height + labelHeight + labelHeight + 15;
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat borderWidth = 1.0 / [UIScreen mainScreen].scale;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    view.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];
    
    DGLabel *label = [[DGLabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width/2, 30)];
    [label setText:playerName];
    label.layer.borderWidth = borderWidth;
    label.layer.borderColor = [design getTintColorSchema].CGColor;
    
    [view addSubview:label];
    
    label = [[DGLabel alloc] initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, 30)];
    [label setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"user"]];
    [label setTextColor:[design getTintColorSchema]];
    label.layer.borderWidth = borderWidth;
    label.layer.borderColor = [design getTintColorSchema].CGColor;
    
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
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    Chat *dict = chatHistoryArray[indexPath.row];
    
    int labelHeight = 25;
    int x = 0;
    int y = 0;
    
    DGLabel *label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, cell.frame.size.width, labelHeight)];
    [label setText:[NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:dict.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle]]];
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
    y += labelHeight;
    
    label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, cell.frame.size.width, labelHeight)];
    switch (dict.typ)
    {
        case CHATHISTORY_QUICKMESSAGE:
            [label setText:@"Quick message"];
            break;
        case CHATHISTORY_MATCH:
            [label setText:dict.matchName];
            break;
        default:
            break;
    }
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
    y += labelHeight;
    
    int labelForTextHeight = cell.contentView.frame.size.height-labelHeight-labelHeight;
    
    if([dict.autorID isEqualToString:dict.userID])
    {
        x = 50;
        label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, cell.frame.size.width-55, labelForTextHeight)];
        [label setTextColor:[design getTintColorSchema]];
        label.layer.borderWidth = 1;
        label.layer.cornerRadius = 14.0f;
        label.layer.borderColor = [design getTintColorSchema].CGColor;
        
    }
    else
    {
        x = 5;
        label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y, cell.frame.size.width-10, labelForTextHeight)];
        label.layer.borderWidth = 1;
        label.layer.cornerRadius = 14.0f;
    }
    [label setText:[self trimLeadingAndTrailingNewlinesFromString:dict.text]];
    label.numberOfLines = 0;
    label.adjustsFontSizeToFitWidth = YES;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [cell.contentView addSubview:label];
    
    return cell;
}

#pragma mark - Table view delegate

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
        Chat *dict = chatHistoryArray[indexPath.row];
        NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@",dict.date];
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
            XLog(@"Error deleting Chat %@", [error localizedDescription]);
        }
        
        [self readArray];
        [self.tableView reloadData];
    }
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
    [self.editButton.rightAnchor   constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.editButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.editButton.widthAnchor  constraintEqualToConstant:60].active = YES;
    
#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.header.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.header.centerXAnchor   constraintEqualToAnchor:safe.centerXAnchor constant:0].active = YES;
    [self.header.heightAnchor constraintEqualToConstant:35].active = YES;
    
#pragma mark tableView autoLayout
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.tableView.topAnchor    constraintEqualToAnchor:self.doneButton.bottomAnchor                constant:gap].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor                constant:-edge].active = YES;
    [self.tableView.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.tableView.rightAnchor  constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
}

#pragma mark - Tools
- (void)saveChat:(NSString *)text
      opponentID:(NSString *)opponentID
         autorID:(NSString *)autorID
             typ:(int)typ
     matchNumber:(int)matchNumber
       matchName:(NSString *)matchName
{
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    NSError *error;
    
    Chat *chatNew = (Chat *)[NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:context];
    chatNew.date       = [NSDate now];
    chatNew.autorID    = autorID;
    chatNew.userID     = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERID"];
    chatNew.typ        = typ;
    chatNew.match      = matchNumber;
    chatNew.matchName  = matchName;
    chatNew.text       = text;
    chatNew.opponentID = opponentID;
    
    if (![context save:&error])
    {
        // Something's gone seriously wrong
        NSLog(@"Error saving Chat");
    }
    
}

- (NSString *)trimLeadingAndTrailingNewlinesFromString:(NSString *)inputString
{
    // Find the number of leading line breaks
    NSUInteger leadingNewlinesCount = 0;
    for (NSUInteger i = 0; i < inputString.length; i++)
    {
        unichar character = [inputString characterAtIndex:i];
        if (character == '\n')
        {
            leadingNewlinesCount++;
        }
        else
        {
            break;
        }
    }
    
    // Find the number of trailing line breaks
    NSUInteger trailingNewlinesCount = 0;
    for (NSInteger i = inputString.length - 1; i >= 0; i--)
    {
        unichar character = [inputString characterAtIndex:i];
        if (character == '\n')
        {
            trailingNewlinesCount++;
        }
        else
        {
            break;
        }
    }
    
    // Remove leading and trailing line breaks
    NSRange trimmedRange = NSMakeRange(leadingNewlinesCount, inputString.length - leadingNewlinesCount - trailingNewlinesCount);
    NSString *trimmedString = [inputString substringWithRange:trimmedRange];
    
    return trimmedString;
}

- (NSString *)removeLinesStartingWithGreaterThan:(NSString *)inputText 
{
    // Divide the input text into lines
    NSArray *lines = [inputText componentsSeparatedByString:@"\n"];
    
    NSMutableString *outputText = [NSMutableString string];
    
    for (NSString *line in lines) 
    {
        if (![line hasPrefix:@">"]) 
        {
            [outputText appendFormat:@"%@\n", line];
        }
    }
    
    // Remove the last character, which is a superfluous line break
    if (outputText.length > 0) {
        [outputText deleteCharactersInRange:NSMakeRange(outputText.length - 1, 1)];
    }
    
    return outputText;
}

@end
