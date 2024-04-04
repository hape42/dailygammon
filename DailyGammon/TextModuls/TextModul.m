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

@interface TextModul ()

@property (weak, nonatomic) IBOutlet DGButton *doneButton;
@property (weak, nonatomic) IBOutlet DGButton *editButton;
@property (weak, nonatomic) IBOutlet DGButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TextModul

@synthesize design;
@synthesize textModulArray;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    design = [[Design alloc] init];
    
    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    textModulArray = [[NSMutableArray alloc] initWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1], @"number",
                              [NSNumber numberWithInt:5], @"quantityUsed",
                              [NSNumber numberWithFloat:50], @"cellHeight",
                              @"Hi & GL", @"shortText",
                              @"Hi & Good luck", @"longText",
                              nil],
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:2], @"number",
                              [NSNumber numberWithInt:3], @"quantityUsed",
                              [NSNumber numberWithFloat:50], @"cellHeight",
                              @"congrats", @"shortText",
                              @"Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win Congrats to your win YES!!!", @"longText",
                              nil],
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:3], @"number",
                              [NSNumber numberWithInt:9], @"quantityUsed",
                              [NSNumber numberWithFloat:50], @"cellHeight",
                              @"TY GM", @"shortText",
                              @"Thank youu. Was a good match", @"longText",
                              nil],
                             nil];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 14.0f;
    self.tableView.layer.borderColor = [design getTintColorSchema].CGColor;

    [self layoutObjects];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
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
    
    NSMutableDictionary *dict = self.textModulArray[indexPath.row];

     // Hier kannst du die Schriftgröße und andere Attribute für den Text festlegen
     UIFont *font = [UIFont systemFontOfSize:15.0]; // Zum Beispiel

     // Hier wird die Breite der Zelle festgelegt, z.B. die Breite der TableView
     CGFloat cellWidth = tableView.frame.size.width - 100;

     // Hier wird die maximale Höhe für die Zelle festgelegt, falls der Text sehr lang ist
     CGFloat maxHeight = 200;

     // Hier wird die Größe des Textes unter Berücksichtigung der Schriftgröße, Breite und Höhe berechnet
     CGSize textSize = [[dict objectForKey:@"longText"] boundingRectWithSize:CGSizeMake(cellWidth, maxHeight)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: font}
                                          context:nil].size;

     // Hier wird die Höhe der Zelle festgelegt, unter Berücksichtigung des Textes und eventueller zusätzlicher Abstände
    int labelHeight = 30;

    CGFloat cellHeight = textSize.height + labelHeight + 20;/* zusätzlicherAbstand */; // Hier kannst du zusätzliche Abstände hinzufügen, wenn nötig
    XLog(@" cellHeight%3.1f",cellHeight);
    [dict setValue:[NSNumber numberWithFloat:cellHeight] forKey:@"cellHeight"];
     return cellHeight;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];

    DGLabel *label = [[DGLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
   [label setText:@"used"];
   [view addSubview:label];
    label = [[DGLabel alloc] initWithFrame:CGRectMake(50, 0, tableView.frame.size.width-50, 25)];
   [label setText:@"Text"];
   [view addSubview:label];
   return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//    }
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
    if (indexPath.row % 2)
        cell.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];
    else
        cell.backgroundColor = [UIColor colorNamed:@"ColorButtonGradientCenter"];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *dict = self.textModulArray[indexPath.row];

    int x = 0;
    int labelHeight = 25;
    
    UILabel *used = [[UILabel alloc] initWithFrame:CGRectMake(x, 0 ,50,labelHeight)];
    used.textAlignment = NSTextAlignmentCenter;
    used.text = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"quantityUsed"]intValue]];
    [cell.contentView addSubview:used];

    x += 50;
    
    DGLabel *nameLabel = [[DGLabel alloc] initWithFrame:CGRectMake(x, 0 ,tableView.frame.size.width-50,labelHeight)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = [NSString stringWithFormat:@"%@ %3.1f", [dict objectForKey:@"shortText"], [[dict objectForKey:@"cellHeight"]floatValue] ];
  //  nameLabel.textColor = [design getTintColorSchema] ;
    [cell.contentView addSubview:nameLabel];
    
    x = 0;
    DGLabel *longtext = [[DGLabel alloc] initWithFrame:CGRectMake(x, labelHeight ,tableView.frame.size.width,cell.contentView.frame.size.height-labelHeight)];
    longtext.textAlignment = NSTextAlignmentLeft;
    longtext.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"longText"]];
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
    NSDictionary *dict = self.textModulArray[indexPath.row];
}

- (IBAction)editAction:(id)sender {
}
- (IBAction)addAction:(id)sender {
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
    [self.editButton.rightAnchor   constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;
    [self.editButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.editButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark addButton autoLayout
    [self.addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.addButton.topAnchor    constraintEqualToAnchor:safe.topAnchor  constant:edge].active = YES;
    [self.addButton.rightAnchor   constraintEqualToAnchor:self.editButton.leftAnchor constant:-edge].active = YES;
    [self.addButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.addButton.widthAnchor  constraintEqualToConstant:60].active = YES;

#pragma mark tableView autoLayout
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.tableView.topAnchor    constraintEqualToAnchor:self.doneButton.bottomAnchor                constant:gap].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor                constant:-edge].active = YES;
    [self.tableView.leftAnchor   constraintEqualToAnchor:safe.leftAnchor constant:edge].active = YES;
    [self.tableView.rightAnchor  constraintEqualToAnchor:safe.rightAnchor constant:-edge].active = YES;

}


@end
