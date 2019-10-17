//
//  HeaderTest.h
//  DailyGammon
//
//  Created by Peter on 30.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#ifndef HeaderTest_h
#define HeaderTest_h


-(UIView *)makeHeader
{
    design = [[Design alloc] init];
    tools = [[Tools alloc] init];

    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, maxBreite - 40, 50)];
    
    int x = 0;
    int y = 5;
    int diceBreite = 40;
    int luecke = 10;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    int countDB = [app.dbConnect countRating];
    int minDB = 5;
    int anzahlButtons = 6;
    if(countDB > minDB)
        anzahlButtons = 7;
//    int anzahlButtons = 7;
//    if(countDB > minDB)
//        anzahlButtons = 8;
    int headerBreite = headerView.frame.size.width;

    int buttonBreite = (headerBreite - diceBreite - (anzahlButtons * luecke) ) / anzahlButtons;
    
    int buttonHoehe = 35;
        
    int boardSchema = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue];
    if(boardSchema < 1)
        boardSchema = 4;
    NSString *imageName = @"dice_rot.png";
    switch(boardSchema)
    {
        case 1:
        case 2:
            imageName = @"dice_gruen.png";
            break;
        case 3:
            imageName = @"dice_blau.png";
            break;
        case 4:
            imageName = @"dice_rot.png";
        break;
            
    }
    UIImageView *diceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    diceView.frame = CGRectMake(0, 5, diceBreite, diceBreite);
    
    x +=  diceBreite + luecke;
    
//    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.topPageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.topPageButton = [design makeNiceButton:self.topPageButton];
    [self.topPageButton setTitle:[NSString stringWithFormat:@"%d Top Page", [tools matchCount]] forState: UIControlStateNormal];
    self.topPageButton.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    self.topPageButton.tag = 1;
    [self.topPageButton addTarget:self action:@selector(topPageVC) forControlEvents:UIControlEventTouchUpInside];
    
    x += buttonBreite + luecke;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2 = [design makeNiceButton:button2];
    [button2 setTitle:@"Game Lounge" forState: UIControlStateNormal];
    button2.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button2.tag = 2;
    [button2 addTarget:self action:@selector(GameLoungeVC) forControlEvents:UIControlEventTouchUpInside];

    x += buttonBreite + luecke;
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    button3 = [design makeNiceButton:button3];
    [button3 setTitle:@"Help" forState: UIControlStateNormal];
    button3.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button3.tag = 3;
    [button3 addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];

    x += buttonBreite + luecke;
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    button4 = [design makeNiceButton:button4];
    [button4 setTitle:@"Settings" forState: UIControlStateNormal];
    button4.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button4.tag = 4;
    [button4 addTarget:self action:@selector(popoverSetUp:) forControlEvents:UIControlEventTouchUpInside];

    x += buttonBreite + luecke;
 
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeSystem];
    button5 = [design makeNiceButton:button5];
    [button5 setTitle:@"Log Out" forState: UIControlStateNormal];
    button5.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button5.tag = 5;
    [button5 addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];

    x += buttonBreite + luecke;

    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeSystem];
    button6 = [design makeNiceButton:button6];
    [button6 setTitle:@"About" forState: UIControlStateNormal];
    button6.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button6.tag = 6;
    [button6 addTarget:self action:@selector(showPopOverAbout:) forControlEvents:UIControlEventTouchUpInside];

    x += buttonBreite + luecke;
    
    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeSystem];
    button7 = [design makeNiceButton:button7];
    [button7 setTitle:@"Rating" forState: UIControlStateNormal];
    button7.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button7.tag = 7;
    [button7 addTarget:self action:@selector(ratingVC) forControlEvents:UIControlEventTouchUpInside];
    
    if(countDB > minDB)
        x += buttonBreite + luecke;

    UIButton *button8 = [UIButton buttonWithType:UIButtonTypeSystem];
    button8 = [design makeNiceButton:button8];
    [button8 setTitle:@"Player" forState: UIControlStateNormal];
    button8.frame = CGRectMake(x, y, buttonBreite - 10, buttonHoehe);
    button8.tag = 8;
    [button8 addTarget:self action:@selector(playerVC) forControlEvents:UIControlEventTouchUpInside];

    [headerView addSubview:diceView];
    
    [headerView addSubview:self.topPageButton];
    [headerView addSubview:button2];
    [headerView addSubview:button3];
    [headerView addSubview:button4];
    [headerView addSubview:button5];
    [headerView addSubview:button6];
    if(countDB > minDB)
        [headerView addSubview:button7];
//    [headerView addSubview:button8];

    return headerView;
}
-(void) ratingVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    RatingVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"RatingVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) topPageVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) GameLoungeVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    GameLounge *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"GameLoungeVC"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)popoverSetUp:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIViewController *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"SetUpVC"];
    
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;
}

- (void)logout
{
    NSURL *urlMatch = [NSURL URLWithString:@"http://dailygammon.com/bg/logout"];
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    NSString *matchString = [[NSString alloc] initWithContentsOfURL:urlMatch
                                                       usedEncoding:&encoding
                                                              error:&error];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    TopPageVC *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"TopPageVC"];

    [self.navigationController pushViewController:vc animated:NO];

}
- (IBAction)showPopOverAbout:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIViewController *controller = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"About"];
    
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    popController.sourceView = button;
    popController.sourceRect = button.bounds;

}
-(void) help
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dailygammon.com/help"] options:@{} completionHandler:nil];
}

- (IBAction)playerVC
{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *vc = [app.activeStoryBoard instantiateViewControllerWithIdentifier:@"PlayerVC"];
    
    [self.navigationController pushViewController:vc animated:NO];

}

#endif /* HeaderTest_h */
