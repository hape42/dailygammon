//
//  Header.m
//  DailyGammon
//
//  Created by Peter on 27.11.18.
//  Copyright © 2018 Peter Schneider. All rights reserved.
//

#import "Header.h"
#import "Design.h"
#import "TopPageVC.h"

@implementation Header

@synthesize design;

-(UIView *)makeHeader
{
    design = [[Design alloc] init];
    
    int maxBreite = [UIScreen mainScreen].bounds.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 20, maxBreite - 20, 50)];
    
    int x = 0;
    int diceBreite = 40;
    int luecke = 10;

    int headerBreite = headerView.frame.size.width;
//    int titelBreite = 200;
    int buttonBreite = (headerBreite - diceBreite - (6*luecke) ) / 6;
    
    UIImageView *diceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dice.png"]];
    diceView.frame = CGRectMake(0, 5, diceBreite, diceBreite);
    
    x +=  diceBreite + luecke;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1 = [design makeNiceButton:button1];
    [button1 setTitle:@"Top Page" forState: UIControlStateNormal];
    button1.frame = CGRectMake(x, 5, buttonBreite - 10, 35);
    button1.tag = 1;
    [button1 addTarget:self action:@selector(topPageVC) forControlEvents:UIControlEventTouchUpInside];

    x += buttonBreite + luecke;

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2 = [design makeNiceButton:button2];
    [button2 setTitle:@"Game Lounge" forState: UIControlStateNormal];
    button2.frame = CGRectMake(x, 5, buttonBreite - 10, 35);
    button2.tag = 2;

    x += buttonBreite + luecke;

    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3 = [design makeNiceButton:button3];
    [button3 setTitle:@"Discussion" forState: UIControlStateNormal];
    button3.frame = CGRectMake(x, 5, buttonBreite - 10, 35);
    button3.tag = 3;

    x += buttonBreite + luecke;

    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4 = [design makeNiceButton:button4];
    [button4 setTitle:@"Links" forState: UIControlStateNormal];
    button4.frame = CGRectMake(x, 5, buttonBreite - 10, 35);
    button4.tag = 4;
    
    x += buttonBreite + luecke;

    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5 = [design makeNiceButton:button5];
    [button5 setTitle:@"Log Out" forState: UIControlStateNormal];
    button5.frame = CGRectMake(x, 5, buttonBreite - 10, 35);
    button5.tag = 5;
    
    x += buttonBreite + luecke;

    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    button6 = [design makeNiceButton:button6];
    [button6 setTitle:@"Help" forState: UIControlStateNormal];
    button6.frame = CGRectMake(x, 5, buttonBreite - 10, 35);
    button6.tag = 6;

//    UILabel *titel = [[UILabel alloc]initWithFrame:CGRectMake(x, 5, titelBreite, 50)];
//    titel.textColor = GRAYLIGHT;
//    titel.textAlignment = NSTextAlignmentCenter;
//    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"Daily Gammon"];
//    [attr addAttribute:NSFontAttributeName
//                  value:[UIFont systemFontOfSize:40.0]
//                  range:NSMakeRange(0, [attr length])];
//    [titel setAttributedText:attr];
//    titel.adjustsFontSizeToFitWidth = YES;
//    titel.numberOfLines = 0;
//    titel.minimumScaleFactor = 0.5;

    [headerView addSubview:diceView];
    
    [headerView addSubview:button1];
    [headerView addSubview:button2];
    [headerView addSubview:button3];
    [headerView addSubview:button4];
    [headerView addSubview:button5];
    [headerView addSubview:button6];

//    [headerView addSubview:titel];
    
    return headerView;
}

-(void) topPageVC
{
    
    TopPageVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TopPageVC"];
   
    [self.navigationController pushViewController:vc animated:YES];

    

}
@end
