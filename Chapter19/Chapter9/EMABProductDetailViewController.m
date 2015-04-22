//
//  EMABProductDetailViewController.m
//  Chapter7
//
//  Created by Liangjun Jiang on 4/19/15.
//  Copyright (c) 2015 Liangjun Jiang. All rights reserved.
//

#import "EMABProductDetailViewController.h"
#import "EMABProduct.h"
#import <ParseUI/PFImageView.h>
#import "EMABUser.h"
#import "EMABFavoriteProduct.h"
#import "EMABOrder.h"
#import "EMABOrderItem.h"

@interface EMABProductDetailViewController ()
@property (nonatomic, weak) IBOutlet PFImageView *fullsizeImageView;
@property (nonatomic, weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *productPriceLabel;
@property (nonatomic, weak) IBOutlet UITextView *detailTextView;
@property (nonatomic, weak) IBOutlet UIButton *heartButton;
@property (nonatomic, strong) EMABOrder *order;

@end

@implementation EMABProductDetailViewController

-(void)setProduct:(EMABProduct *)product{
    if (_product !=product) {
        _product = product;
        
        [self updateUI];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

-(void)updateUI{
    if (self.product.fullsizeImage) {
       self.fullsizeImageView.file = self.product.fullsizeImage;
    }
    
    [self.fullsizeImageView loadInBackground];
    self.productNameLabel.text = self.product.name;
    self.productPriceLabel.text = [self.product friendlyPrice];
    self.detailTextView.text = [self.product detail];
    
    if (![PFAnonymousUtils isLinkedWithUser:[EMABUser currentUser]]) {
        [self queryForUnfinishedOrder];
    }
}


-(IBAction)onBag:(id)sender
{
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showWarning];
    } else {
        //todo:
        if (self.order) {
            
        } else {
            EMABOrder *order = [EMABOrder object];
            [order setCustomer:[EMABUser currentUser]];
            [order setOrderStatus:ORDER_NOT_MADE];
            EMABOrderItem *item = [EMABOrderItem object];
            [item setProduct:self.product];
            [item setQuantity:1];
            [order setItems:@[item]];
            [order saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                if (!error) {
                    //show success
                }
            }];
            
        }
    }
    
}


-(IBAction)onFavorite:(id)sender{
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showWarning];
    } else {
        EMABFavoriteProduct *favoriteProduct = [EMABFavoriteProduct object];
        [favoriteProduct setCustomer:[PFUser currentUser]];
        [favoriteProduct setProduct:self.product];
        [favoriteProduct saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (!error) {
                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success") message:NSLocalizedString(@"Successfully added", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil] show];
            }
        }];
    }
}


-(IBAction)onShare:(id)sender {
    
    NSString *textToShare = [NSString stringWithFormat:@"%@, %@", self.product.name, [self.product friendlyPrice]];
    NSURL *imageUrl = [NSURL URLWithString:self.product.fullsizeImage.url];
    
    NSArray *objectsToShare = @[textToShare, imageUrl];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Order not checkedout
-(void)queryForUnfinishedOrder{
    PFQuery *orderQuery = [EMABOrder queryForCustomer:[EMABUser currentUser] orderStatus:ORDER_NOT_MADE];
    [orderQuery getFirstObjectInBackgroundWithBlock:^(PFObject *order, NSError *error){
        if (!error) {
            self.order = (EMABOrder *)order;
        }
    }];
    
}


#pragma mark - helper
-(void)checkIfFavorited
{
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFQuery *fPQuery = [EMABFavoriteProduct queryForCustomer:[PFUser currentUser] product:self.product];
        [fPQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (!error) {
                self.heartButton.enabled = false;
            }
        }];
    }
}


-(void)showWarning
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Warning") message:NSLocalizedString(@"Please sign up or log in", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil] show];
}

//hear.png http://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Heart_coraz%C3%B3n.svg/2000px-Heart_coraz%C3%B3n.svg.png

@end
