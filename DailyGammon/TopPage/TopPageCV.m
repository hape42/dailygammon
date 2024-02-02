//
//  TopPageCV.m
//  DailyGammon
//
//  Created by Peter Schneider on 31.01.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "TopPageCV.h"
#import "DGButton.h"
#import "DGLabel.h"
#import "Constants.h"
#import "Design.h"

@interface TopPageCV ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet DGButton *refreshButton;
@property (weak, nonatomic) IBOutlet DGButton *sortButton;
@property (weak, nonatomic) IBOutlet UILabel *sortLabel;

@end

@implementation TopPageCV

@synthesize menueView, sortView;
@synthesize design;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    design      = [[Design alloc] init];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reDrawHeader) name:changeSchemaNotification object:nil];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self layoutObjects];
    [self reDrawHeader];

}

-(void) reDrawHeader
{
    NSMutableDictionary *schemaDict = [design schema:[[[NSUserDefaults standardUserDefaults] valueForKey:@"BoardSchema"]intValue]];
    self.header.textColor = [schemaDict objectForKey:@"TintColor"];
    self.moreButton = [design designMoreButton:self.moreButton];
    self.sortLabel.textColor = [schemaDict objectForKey:@"TintColor"];
}

#pragma mark - autoLayout
-(void)layoutObjects
{
    UIView *superview = self.view;
    UILayoutGuide *safe = superview.safeAreaLayoutGuide;
    float edge = 5.0;
    
#pragma mark moreButton autoLayout
    [self.moreButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Top space to superview Y
    NSLayoutConstraint *moreButtonYConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:superview
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:44];
    //  position X
    NSLayoutConstraint *moreButtonXConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:superview
                                                                             attribute: NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:-edge];

    // Fixed width
    NSLayoutConstraint *moreButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:40];
    // Fixed Height
    NSLayoutConstraint *moreButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.moreButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:40];

    [superview addConstraints:@[moreButtonXConstraint, moreButtonYConstraint, moreButtonWidthConstraint, moreButtonHeightConstraint]];

#pragma mark refreshButton autoLayout
    [self.refreshButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    // position Y
    NSLayoutConstraint *refreshButtonYConstraint = [NSLayoutConstraint constraintWithItem:self.refreshButton
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.moreButton
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.0f
                                                                              constant:0];
    //  position X
    NSLayoutConstraint *refreshButtonXConstraint = [NSLayoutConstraint constraintWithItem:self.refreshButton
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:superview
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:edge];

    // Fixed width
    NSLayoutConstraint *refreshButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.refreshButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:70];
    // Fixed Height
    NSLayoutConstraint *refreshButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.refreshButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:35];

    [superview addConstraints:@[refreshButtonXConstraint, refreshButtonYConstraint, refreshButtonWidthConstraint, refreshButtonHeightConstraint]];

#pragma mark sortLabel autoLayout
    [self.sortLabel setTranslatesAutoresizingMaskIntoConstraints:NO];


    // position Y
    NSLayoutConstraint *sortLabelYConstraint = [NSLayoutConstraint constraintWithItem:self.sortLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.refreshButton
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0f
                                                                              constant:20];
    //  position X
    NSLayoutConstraint *sortLabelXConstraint = [NSLayoutConstraint constraintWithItem:self.sortLabel
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute: NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:edge];

    // Fixed width
    NSLayoutConstraint *sortLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.sortLabel
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:130];
    // Fixed Height
    NSLayoutConstraint *sortLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.sortLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:35];

    [superview addConstraints:@[sortLabelXConstraint, sortLabelYConstraint, sortLabelWidthConstraint, sortLabelHeightConstraint]];

#pragma mark sortButton autoLayout
    [self.sortButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    // position Y
    NSLayoutConstraint *sortButtonYConstraint = [NSLayoutConstraint constraintWithItem:self.sortButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.sortLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];
    //  position X
    NSLayoutConstraint *sortButtonXConstraint = [NSLayoutConstraint constraintWithItem:self.sortButton
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.sortLabel
                                                                             attribute: NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:10.0f];

    // Fixed width
    NSLayoutConstraint *sortButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.sortButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:190];
    // Fixed Height
    NSLayoutConstraint *sortButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.sortButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:35];

    [superview addConstraints:@[sortButtonXConstraint, sortButtonYConstraint, sortButtonWidthConstraint, sortButtonHeightConstraint]];

#pragma mark collectionView autoLayout
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *collectionViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:safe
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:edge];
    NSLayoutConstraint *collectionViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:safe
                                                                                 attribute: NSLayoutAttributeRight
                                                                                multiplier:1.0
                                                                                  constant:-edge];
    
    NSLayoutConstraint *collectionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.sortLabel
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:20];

    NSLayoutConstraint *collectionViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:-edge];

   [superview addConstraints:@[collectionViewLeftConstraint, collectionViewRightConstraint, collectionViewTopConstraint, collectionViewBottomConstraint]];

}
#pragma mark - CollectionView dataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(300, 200);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[DGLabel class]])
        {
            [subview removeFromSuperview];
        }
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }
    cell.layer.cornerRadius = 14.0f;
    cell.layer.masksToBounds = YES;

    return cell;



}

- (IBAction)moreAction:(id)sender
{
    if(!menueView)
    {
        menueView = [[MenueView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [menueView showMenueInView:self.view];
}

- (IBAction)sortAction:(id)sender
{
    if(!sortView)
    {
        sortView = [[SortView alloc]init];
        menueView.navigationController = self.navigationController;
    }
    [sortView showMenueInView:self.view];
}

@end
