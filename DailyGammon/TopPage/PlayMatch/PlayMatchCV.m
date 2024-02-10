//
//  PlayMatchCV.m
//  DailyGammon
//
//  Created by Peter Schneider on 04.02.24.
//  Copyright © 2024 Peter Schneider. All rights reserved.
//

#import "PlayMatchCV.h"
#import "DGLabel.h"

@interface PlayMatchCV ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *header;

@end

@implementation PlayMatchCV

@synthesize menueView, waitView;

- (void)viewDidLoad 
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorNamed:@"ColorTournamentCell"];;
    self.collectionView.backgroundColor = [UIColor colorNamed:@"ColorViewBackground"];;

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self layoutObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)orientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    // Überprüfen Sie die aktuelle Ausrichtung und führen Sie die gewünschten Aktionen durch
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            NSLog(@"Portrait orientation");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"Landscape Left orientation");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"Landscape Right orientation");
            break;
        // ... weitere Orientierungen je nach Bedarf
        default:
            break;
    }
    [self.collectionView reloadData];

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
#pragma mark - CollectionView dataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 0.0;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 0.0;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float edge = 5;

    int maxHeight = self.collectionView.frame.size.height * .8;
    int maxWidth = self.collectionView.frame.size.width * .8;

    float boardWidth  = 660;
    float boardHeight = 504;
    float zoomFactor = 1.0;
    
    float cell1Width = 100;
    float cell1Height = 100;

    float cell2Width = 100;
    float cell2Height = 100;

    if(maxWidth > maxHeight)
    {
        zoomFactor = maxHeight / boardHeight;
        zoomFactor *= .98;
        cell1Width = boardWidth * zoomFactor;
        cell1Height = boardHeight *zoomFactor;
        
        cell2Width = maxWidth - cell1Width; // minimum breite setzen und boradVie ggfs wieder kleiner machen
        cell2Height = cell1Height;
    }
    else
    {
        zoomFactor = maxWidth / boardWidth;
        zoomFactor *= .98;

        cell1Width = boardWidth * zoomFactor;
        cell1Height = boardHeight *zoomFactor;

        cell2Width = cell1Width;
        cell2Height = maxHeight - cell1Height;  // maximale hoehe festelegen

    }
    switch (indexPath.row)
    {
        case 0:
            return CGSizeMake(cell1Width, cell1Height);

            break;
        case 1:
            return CGSizeMake(cell2Width, cell2Height);

            break;

        default:
            break;
    }
    return CGSizeMake(250, 250);
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
    cell.backgroundColor = [UIColor colorNamed:@"ColorCV"];

    int mainScreenMaxWidth  = [UIScreen mainScreen].bounds.size.width;
    int mainScreenMaxHeight = [UIScreen mainScreen].bounds.size.height;

    float edge = 5;
    float gap = 5;
    float x = edge;
    float y = edge;
    float maxWidth = cell.frame.size.width - edge - edge;
    int labelHeight = 35;
    
    DGLabel *label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth,labelHeight)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [NSString stringWithFormat:@"collectionView w %d  h %d", self.collectionView.frame.size.width, self.collectionView.frame.size.height];
    label.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label];

    y += labelHeight;
    label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth,labelHeight)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [NSString stringWithFormat:@"self.view w %3.1f  h %3.1f", self.view.bounds.size.width, self.view.bounds.size.height];
    label.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label];
    
    y += labelHeight;
    label = [[DGLabel alloc] initWithFrame:CGRectMake(x, y ,maxWidth,labelHeight)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [NSString stringWithFormat:@"cell w %3.1f  h %3.1f", cell.bounds.size.width, cell.bounds.size.height];
    label.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label];
    
    if(indexPath.row == 0)
        cell.backgroundColor = UIColor.yellowColor;
    else
        cell.backgroundColor = UIColor.purpleColor;

    return cell;

}

#pragma mark - CollectionView delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - autoLayout

-(BOOL)prefersStatusBarHidden 
{
    // maximize view
    return YES;
}

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
                                                                              constant:0];
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

#pragma mark header autoLayout
    [self.header setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *headerYConstraint = [NSLayoutConstraint constraintWithItem:self.header
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0];
    NSLayoutConstraint *headerLeftConstraint = [NSLayoutConstraint constraintWithItem:self.header
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:safe
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:edge];
    NSLayoutConstraint *headerRightConstraint = [NSLayoutConstraint constraintWithItem:self.header
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.moreButton
                                                                                 attribute: NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:-edge];
    // Fixed Height
    NSLayoutConstraint *headerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.header
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0
                                                                                   constant:40];

    [superview addConstraints:@[headerYConstraint, headerLeftConstraint, headerRightConstraint, headerHeightConstraint]];

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
                                                                                toItem:self.header
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:5];

    NSLayoutConstraint *collectionViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:safe
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:-edge];

   [superview addConstraints:@[collectionViewLeftConstraint, collectionViewRightConstraint, collectionViewTopConstraint, collectionViewBottomConstraint]];

}
@end
