//
//  DetailViewController.h
//  RottenMangoes
//
//  Created by Alain  on 2015-05-27.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movies.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Movies *detailItem; //this is super important
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;

@end